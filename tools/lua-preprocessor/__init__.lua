local function parseRequire(pieces, chunk, s, e)
	local s = 1
	
	for term, comment, path, e in string.gmatch(chunk, "()([-]*)[ \t]*require%s*(%b())()") do
		if string.len(comment) >= 2 then break end
		
		local name = load('return' .. path, "path")()
		local path = name .. ".lua"
		local file = io.open(path, "rb")
		if not file then s = e break end
		
		local piecesFile = {}
		
		-- table.insert(pieces, "\n\n------ ".. path .." ------\n\n")
		_ENV._package.loaded[name] = true
		_ENV._preprocess(file:read"*a", "require")(function(data)
			table.insert(piecesFile, data)
		end)
		
		file:close()
		
		table.insert(pieces, string.format("%q .. ",
			string.format("%s\nload(%q, %q)()", string.sub(chunk, s, term - 1), table.concat(piecesFile), path))
		)
		
		s = e
	end
	
	table.insert(pieces, string.format("%q", string.sub(chunk, s)))
end

-------------------------------------------------------------------------------

local function parseDollarParen(pieces, chunk, s, e)
	local s = 1
	for term, executed, e in string.gmatch(chunk, "()$(%b())()") do
		parseRequire(pieces, string.sub(chunk, s, term - 1))
		table.insert(pieces, string.format("..(%s or '')..", executed))
		s = e
	end
	
	parseRequire(pieces, string.sub(chunk, s))
	-- table.insert(pieces, string.format("%q", string.sub(chunk, s)))
end

-------------------------------------------------------------------------------

local function parseHashLines(chunk)
	local pieces, s, args = string.find(chunk, "^\n*#ARGS%s*(%b())[ \t]*\n")
	if not args or string.find(args, "^%(%s*%)$") then
		pieces, s = {"return function(_put) ", n = 1}, s or 1
	 else
		pieces = {"return function(_put, ", string.sub(args, 2), n = 2}
	end
	
	table.insert(pieces, "local _OLD_ENV_PUT = _ENV._put\n")
	table.insert(pieces, "_ENV._put = _put\n")
	
	while true do
		local ss, e, lua = string.find(chunk, "^[-]*[ \t]*#+([^\n]*\n?)", s)
		if not e then
			ss, e, lua = string.find(chunk, "\n[-]*[ \t]*#+([^\n]*\n?)", s)
			
			table.insert(pieces, "\n_put(")
			parseDollarParen(pieces, string.sub(chunk, s, ss))
			table.insert(pieces, ")")
			if not e then break end
		end
		
		table.insert(pieces, lua)
		s = e + 1
	end
	
	table.insert(pieces, "\n_ENV._put = _OLD_ENV_PUT\n")
	table.insert(pieces, "end\n")
	
	return table.concat(pieces)
end

-------------------------------------------------------------------------------

local function preprocess(chunk, name)
	local content = parseHashLines(chunk)
	
	-- print("----------------------------S-" .. name)
	-- print(content)
	-- print("----------------------------E-" .. name)
	
	return assert(load(content, name, nil, setmetatable(_G, {
	__index = {
		include = function(path)
			local file = io.open(path, "rb")
			if not file then return nil end
			
			preprocess(file:read"*a", path)(_ENV._put)
			
			file:close()
		end
	}
	})))()
end

-------------------------------------------------------------------------------
-- CGI Stuff                                              ---------------------
-------------------------------------------------------------------------------
-- perl.pm accepts %uxxxx but that is not in any standard that
-- I can find; both the IRI proposal and RFC-2396 say you UTF-8
-- encode and then %-encode byte by byte. So it is not here.
local function unUrlEscape(field)
	field = string.gsub(field, '%+', ' ')
	return string.gsub(field, '%%(%x%x)',
		 function(xx) return string.char(tonumber(xx, 16)) end) 
end

local function parseQuery(q)
	local t = {}
	q = string.gsub(q, "([^&=]+)=([^&;]*)[&;]?", 
		function(name, attr) t[unUrlEscape(name)] = unUrlEscape(attr) end)
	if q ~= "" then
		table.setn(t, 0)
		string.gsub(q, "[^+]*", function(w) table.insert(t, unUrlEscape(w)) end)
	end
	return t
end

-------------------------------------------------------------------------------
-- Sample driver                                          ---------------------
-------------------------------------------------------------------------------
-- get settings from the command line
ARG = {}
for i = 1, #arg do
	local _, _, k, v = string.find(arg[i], "^(%a%w*)=(.*)")
	if k then ARG[k] = v end
end

CGI = {}

-- Variable lookup order: globals, parameters, environment, CGI request
setmetatable(_G, {__index = function(t, k) return ARG[k] or os.getenv(k) or CGI[k] end})

-- decode CGI query if present
-- perl.pm also checks for REDIRECT_QUERY_STRING
if QUERY_STRING and QUERY_STRING ~= "" then
	CGI = parseQuery(QUERY_STRING)
end

_ENV._preprocess = preprocess
_ENV._package = { ['loaded'] = {} }

-- preprocess from stdin to stdout
preprocess(io.read"*a", "out")(io.write)