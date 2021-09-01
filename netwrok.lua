--1.1
local Network = {}

local Key
local Verify

local Byte = string.byte
local Char = string.char
local Sub = string.sub

local HttpService = game:GetService("HttpService")

local GameEvents = game:GetService("ReplicatedStorage").Events
local RemoteEvent = GameEvents:FindFirstChild("RemoteEvent")
local RemoteFunction = GameEvents:FindFirstChild("RemoteFunction")

for _, Func in next, getgc() do
    local FEnv = getfenv(Func)
    if FEnv.script and FEnv.script.Name == "Flux/client" then
        local UpValues = getupvalues(Func)
        if UpValues[5] then
            Key = UpValues[5] -- encoded table with numbers ex: [1, 2, 3, 4]
            Verify = UpValues[4] -- long string ex: 1234-1234-12-1234-1234
            break
        end
    end
end

--print(Key, Verify)

local function ConfuseChar(Character, Offset, SubtractValue)
    -- (string.byte(p1) - 32 +
    -- (p3 and -p2 or p2)) first
    -- then % 95 + 32 and at the end char
    local CByte = Byte(Character) - 32
    CByte = CByte + (SubtractValue and -Offset or Offset)
    CByte = Char(CByte % 95 + 32)
    return CByte
end

local function EncryptArguments(String, Key, SubtractValue)
    local Output = ""
    local StringLenght = string.len(String)

    for Idx = 1, StringLenght do
        if Idx <= StringLenght - Key[5] or not SubtractValue then
            for InnerIdx = 0, 3 do
                if Idx % 4 == InnerIdx then
                    Output = Output .. ConfuseChar(Sub(String, Idx, Idx), Key[InnerIdx + 1], SubtractValue)
                    break
                end
            end
        end
    end
    if not SubtractValue then
        for Idx = 1, Key[5] do
            Output = Output .. Char(Byte(String) - Byte(Idx))
        end
    end
    return Output
end

function Network:FireServer(...)
    RemoteEvent:FireServer(EncryptArguments(HttpService:JSONEncode({Verify, ...}), HttpService:JSONDecode(Key)))
end

function Network:InvokeServer(...)
    return RemoteFunction:InvokeServer(EncryptArguments(HttpService:JSONEncode({Verify, ...}), HttpService:JSONDecode(Key)))
end

return Network
