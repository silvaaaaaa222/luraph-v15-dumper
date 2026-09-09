#!/usr/bin/env lua
-- Luraph v15 Dumper
-- Hook loadstring para capturar código descriptografado

local function dump_file(filename)
    local file = io.open(filename, "r")
    if not file then
        print("❌ Erro: arquivo não encontrado: " .. filename)
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    print("📂 Arquivo carregado: " .. filename .. " (" .. #content .. " bytes)")
    
    -- Hook do loadstring
    local original_loadstring = loadstring or load
    local dumped_code = nil
    
    local hooked_loadstring = function(code, ...)
        print("\n🎯 CÓDIGO INTERCEPTADO! Tamanho: " .. tostring(#code) .. " bytes")
        dumped_code = code
        
        -- Salva em arquivo
        local out = io.open("output_dumped.lua", "w")
        out:write(code)
        out:close()
        print("✅ Salvo em: output_dumped.lua")
        
        -- Tenta executar
        return original_loadstring(code, ...)
    end
    
    -- Substitui loadstring globalmente
    _G.loadstring = hooked_loadstring
    if _G.load then
        _G.load = hooked_loadstring
    end
    
    -- Executa o arquivo obfuscado
    print("\n▶️  Executando arquivo obfuscado...\n")
    local success, result = pcall(function()
        return dofile(filename)
    end)
    
    if success then
        print("\n✅ Execução bem-sucedida!")
        if dumped_code then
            print("📝 Código descriptografado capturado!")
        end
    else
        print("\n⚠️  Erro na execução: " .. tostring(result))
    end
end

-- Pega o arquivo como argumento
local target_file = arg[1] or "25ms_get.lua.txt"
dump_file(target_file)
