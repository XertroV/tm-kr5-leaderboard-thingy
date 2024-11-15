const string PluginName = Meta::ExecutingPlugin().Name;
const string MenuIconColor = "\\$f5d";
const string PluginIcon = "\\$s\\$o\\$i" + Icons::Crosshairs;
const string MenuTitle = MenuIconColor + PluginIcon + "\\$z " + PluginName;

void Main() {
    startnew(LoadFonts);
    startnew(LoadMapCollection);
    startnew(WatchMapChange);
}

void LoadMapCollection() {
    // g_MapCollection.TestPopulate();
    // @g_CurrMap = g_MapCollection.mapInfos[0];
}

MapCollection g_MapCollection;

uint lastMapIdV = 0;
void WatchMapChange() {
    auto app = GetApp();
    while (true) {
        yield();

        auto currentMapId = GetMapIdV(app.RootMap);
        if (app.Editor !is null) currentMapId = 0;

        if (lastMapIdV != currentMapId) {
            lastMapIdV = currentMapId;
            trace("Map change detected: " + lastMapIdV);
            OnMapChange(app.RootMap);
        }
    }
}

uint GetMapIdV(CGameCtnChallenge@ map) {
    if (map is null) return 0;
    return map.Id.Value;
}

bool f_IsMapInCollection;
MapInfo@ g_CurrMap;

void OnMapChange(CGameCtnChallenge@ map) {
    f_IsMapInCollection = false;
    @g_CurrMap = null;

    // testing
    // g_MapCollection.TestPopulate();
    // @g_CurrMap = g_MapCollection.mapInfos[0];
    // end testing

    if (map is null) {
        // todo: clear map stuff
        return;
    }
    if (map.MapInfo is null) {
        print("MapInfo is null");
        return;
    }

    g_MapCollection.YieldTillInit();

    string mapUid = map.MapInfo.MapUid;
    @g_CurrMap = g_MapCollection.GetMapByUid(mapUid);
    f_IsMapInCollection = g_CurrMap !is null;
    if (f_IsMapInCollection) {
        g_CurrMap.LoadMapLbAsync();
    }
}






uint g_LastPause = Time::Now;
bool g_workPaused = false;
// uint g_lastPauseAfterDuration;
bool CheckPause() {
    if (g_workPaused) {
        while (g_workPaused) {
            yield();
        }
        // return true;
    }
    uint workMs = Time::Now < 60000 ? 1 : 4;
    if (g_LastPause + workMs < Time::Now) {
        g_workPaused = true;
        // g_lastPauseAfterDuration = Time::Now - g_LastPause;
        yield();
        // trace('paused');
        g_LastPause = Time::Now;
        g_workPaused = false;
        return true;
    }
    return false;
}
