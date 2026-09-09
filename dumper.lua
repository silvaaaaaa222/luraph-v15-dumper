#!/usr/bin/env lua
-- Luraph v15 Advanced Dumper
-- Múltiplas estratégias de extração

local captured_code = {}
local original_funcs = {}

local function setup_hooks()
    -- Hook 1: loadstring
    if loadstring then
        original_funcs.loadstring = loadstring
        _G.loadstring = function(code, ...)
            print("🎯 [1] loadstring interceptado!")
            table.insert(captured_code, code)
            return original_funcs.loadstring(code, ...)
        end
    end
    
    -- Hook 2: load (Lua 5.3+)
    if load then
        original_funcs.load = load
        _G.load = function(code, ...)
            print("🎯 [2] load() interceptado!")
            if type(code) == "string" then
                table.insert(captured_code, code)
            end
            return original_funcs.load(code, ...)
        end
    end
    
    -- Hook 3: debug.getinfo
    if debug and debug.getinfo then
        original_funcs.getinfo = debug.getinfo
        debug.getinfo = function(...)
            return original_funcs.getinfo(...)
        end
    end
    
    -- Hook 4: string.dump (pega bytecode compilado)
    if string.dump then
        original_funcs.dump = string.dump
        _G.string.dump = function(func)
            print("🎯 [3] string.dump() interceptado!")
            return original_funcs.dump(func)
        end
    end
end

local function extract_from_table(t, depth, max_depth)
    if depth > (max_depth or 5) then return end
    if type(t) ~= "table" then return end
    
    for k, v in pairs(t) do
        if type(v) == "string" and #v > 100 then
            -- Possível código compactado/criptografado
            if v:match("^[%w%+/%=]+$") or v:match("[^%x00-\x1f%x7f-\xff]") == nil then
                print("📦 Possível string codificada encontrada na chave: " .. tostring(k))
                table.insert(captured_code, v)
            end
        elseif type(v) == "table" then
            extract_from_table(v, depth + 1, max_depth)
        end
    end
end

local function dump_file(filename)
    local file = io.open(filename, "r")
    if not file then
        print("❌ Erro: arquivo não encontrado: " .. filename)
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    print("📂 Arquivo: " .. filename .. " (" .. #content .. " bytes)")
    print("🔍 Configurando hooks...\n")
    
    setup_hooks()
    
    print("▶️  Executando arquivo...\n")
    local success, result = pcall(function()
        return dofile(filename)
    end)
    
    print("\n" .. string.rep("=", 60))
    
    if success then
        print("✅ Execução bem-sucedida!")
        if result and type(result) == "table" then
            print("📊 Analisando tabela retornada...")
            extract_from_table(result, 0, 3)
        end
    else
        print("⚠️  Erro na execução: " .. tostring(result))
    end
    
    print("📝 Códigos capturados: " .. #captured_code)
    
    if #captured_code > 0 then
        print("\n✅ Salvando códigos extraídos...\n")
        local out = io.open("output_dumped.lua", "w")
        
        for i, code in ipairs(captured_code) do
            out:write("-- ===== Código " .. i .. " =====\n")
            out:write(code)
            out:write("\n\n")
        end
        
        out:close()
        print("✅ Salvo em: output_dumped.lua (" .. #captured_code .. " código(s))")
    else
        print("❌ Nenhum código capturado")
        
        -- Tenta extrair do arquivo original
        print("\n🔧 Tentando extrair strings do arquivo original...")
        local chunk = loadstring(content)
        if chunk then
            print("📊 Arquivo pode ser carregado como chunk")
        end
    end
end

local target_file = arg[1] or "25ms_get.lua.txt"
dump_file(target_file)
