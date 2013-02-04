do
    local Rose_oldModBlueprints = ModBlueprints
    function ModBlueprints(all_bps)
        Rose_oldModBlueprints(all_bps)
        for id, bp in all_bps.Unit do
            if not bp.ResolvePath then # skip blueprints that don't have this set for perfomance reasons
                continue
            end
            bp = ResolvePaths(bp)
        end
    end

    # finds a path that starts with [...] , finds the specified file and then corrects the path
    function ResolvePaths(bpTable)
        for k, v in bpTable do
            if type(v) == 'table' then
                bpTable[k] = ResolvePaths(v)
                continue
            elseif type(v) != 'string' or string.len(v) < 8 or string.sub(v, 1, 5) != '[...]' then
                continue
            end
            local partialPath = string.sub(v, 6) # v needs to be > 6 for this, checking v >= 8 two lines up
            local path = ''
            local foundResult = false
            LOG('Resolving full path for '..repr(partialPath))
            for i, m in __active_mods do
                for _,file in DiskFindFiles(m.location, partialPath) do
                    path = file
                    foundResult = true
                    break
                end
                if foundResult then
                    break
                end
            end
            if not foundResult then
                WARN('Cannot resolve full path for partial path '..repr(partialPath))
                continue
            end
            bpTable[k] = path
        end
        return bpTable
    end
end
