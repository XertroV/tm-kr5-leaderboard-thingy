class MapCollection {
    MapInfo[] mapInfos;
    MainResultsEntry[] lb;

    dictionary playerToIx;
    dictionary mapUidToIx;

    int64 resultsRefreshAfter;
    int64 mapsRefreshAfter;

    bool isRefreshing;

    MapCollection() {
        startnew(CoroutineFunc(this.UpdateMainData));
    }

    void UpdateMainData() {
        LoadMapsAsync();
        LoadResultsAsync();
        LoadMapLbsAsync();
    }

    void LoadMapsAsync() {
        isRefreshing = true;
        auto j = MapMonitor::GetKR5Maps();
        mapsRefreshAfter = int64(j["ts"]) + int(j["min_refresh_period"]);
        if (mapsRefreshAfter < Time::Stamp + 120) mapsRefreshAfter = Time::Stamp + 120;
        auto maps = j['maps'];
        mapInfos.Resize(maps.Length);
        for (uint i = 0; i < maps.Length; i++) {
            mapInfos[i].FromJson(maps[i], i);
            mapUidToIx[mapInfos[i].uid] = i;
        }
        isRefreshing = false;
    }

    void LoadResultsAsync() {
        isRefreshing = true;
        auto j = MapMonitor::GetKR5Results();
        resultsRefreshAfter = int64(j["ts"]) + int(j["min_refresh_period"]);
        if (resultsRefreshAfter < Time::Stamp + 120) resultsRefreshAfter = Time::Stamp + 120;
        auto results = j['results'];
        lb.Resize(results.Length);
        for (uint i = 0; i < results.Length; i++) {
            lb[i].FromJson(results[i]);
            playerToIx[lb[i].name] = i;
        }
        isRefreshing = false;
    }

    void LoadMapLbsAsync() {
        trace("Loading map lbs: " + mapInfos.Length);
        for (uint i = 0; i < mapInfos.Length; i++) {
            mapInfos[i].LoadMapLbAsync();
        }
    }

    void YieldTillInit() {
        while (mapInfos.Length == 0 || lb.Length == 0) {
            yield();
        }
    }

    MapInfo@ GetMapByUid(const string &in uid) {
        if (mapUidToIx.Exists(uid)) {
            return mapInfos[int(mapUidToIx[uid])];
        }
        return null;
    }

    void OnPlayerNameChange() {
        for (uint m = 0; m < this.mapInfos.Length; m++) {
            this.mapInfos[m].CheckMyRecord();
        }
    }
}

class MainResultsEntry {
    int rank;
    string name;
    string nameFmt;
    int finishes;
    float average;
    float averageFinished;

    MainResultsEntry() {}

    MainResultsEntry(Json::Value@ j) {
        this.FromJson(j);
    }

    void FromJson(Json::Value@ j) {
        this.rank = int(j[0]);
        this.name = j[1];
        this.nameFmt = Text::OpenplanetFormatCodes(j[2]);
        this.finishes = int(j[3]);
        this.average = float(j[4]);
        this.averageFinished = float(j[5]);
    }
}
