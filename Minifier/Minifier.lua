--[[
  Name: Minifier.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2023-10-XX
  All Rights Reserved.
--]]

--* Dependencies *--
local ModuleManager = require("ModuleManager/ModuleManager"):newFile("Minifier/Minifier")
local Helpers = ModuleManager:loadModule("Helpers/Helpers")

local Lexer = ModuleManager:loadModule("Interpreter/LuaInterpreter/Lexer/Lexer")
local Parser = ModuleManager:loadModule("Interpreter/LuaInterpreter/Parser/Parser")

--* Export library functions *--
local stringifyTable = Helpers.StringifyTable
local find = table.find or Helpers.TableFind
local concat = table.concat
local insert = table.insert
local rep = string.rep

--* Minifier *--
local Minifier = {}
function Minifier:new(tokens)
  local MinifierInstance = {}
  MinifierInstance.tokens = tokens
  MinifierInstance.currentTokenIndex = 1
  MinifierInstance.currentToken = tokens[1]

  function MinifierInstance:peek(n)
    return self.tokens[self.currentTokenIndex + (n or 1)]
  end
  function MinifierInstance:consume(n)
    self.currentTokenIndex = self.currentTokenIndex + (n or 1)
    self.currentToken = self.tokens[self.currentTokenIndex]
    return self.currentToken
  end

  function MinifierInstance:isKeywordOrIdentifierOrNumber(token)
    local tokenType = token and token.TYPE
    return self:isIdentifier(token) or tokenType == "Keyword" or tokenType == "Number"
  end
  function MinifierInstance:isIdentifierOrNumber(token)
    local tokenType = token and token.TYPE
    return self:isIdentifier(token) or tokenType == "Number"
  end
  function MinifierInstance:isIdentifier(token)
    local tokenType = token and token.TYPE
    local tokenValue = token and token.Value
    local identifierOperators = {"and", "or", "not"}

    return tokenType == "Identifier" or (tokenType == "Constant" and tokenValue ~= "...") or
          ((tokenType == "Operator" or tokenType == "UnaryOperator") and find(identifierOperators, tokenValue))
  end
  function MinifierInstance:isKeyword(token)
    local tokenType = token and token.TYPE
    return tokenType == "Keyword"
  end
  function MinifierInstance:processCurrentToken()
    local token = self.currentToken
    local tokenValue = token.Value
    local tokenType = token.TYPE
    if tokenType == "Keyword" then
      tokenValue = ((self:isKeywordOrIdentifierOrNumber(self:peek(-1)) and " ") or "") .. tokenValue
    elseif tokenType == "Identifier" then
      tokenValue = ((self:isKeywordOrIdentifierOrNumber(self:peek(-1)) and " ") or "") .. tokenValue
    elseif tokenType == "Number" then
      tokenValue = ((self:isKeywordOrIdentifierOrNumber(self:peek(-1)) and " ") or "") .. tokenValue
    elseif tokenType == "Operator" and self:isIdentifier(token) then
      tokenValue = ((self:isKeywordOrIdentifierOrNumber(self:peek(-1)) and " ") or "") .. tokenValue
    elseif tokenType == "String" then
      tokenValue = "'" .. tokenValue .. "'"
    elseif tokenType == "Constant" then
      tokenValue = ((self:isKeywordOrIdentifierOrNumber(self:peek(-1)) and " ") or "") .. tokenValue
    end
    return tokenValue
  end
  function MinifierInstance:run()
    local strings = {}
    while self.currentToken do
      insert(strings, self:processCurrentToken())
      self:consume()
    end

    return concat(strings)
  end
  return MinifierInstance
end

return Minifier