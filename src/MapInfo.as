
class MapInfo {
    int mapIx;

    string uid;
    string name;
    string nameFmt;

    string wrHolder;
    string wrHolderFmt;
    string author;
    string authorFmt;

    string wrTimeStr;
    string pbTimeStr;
    string avgTimeStr;
    string worstTimeStr;

    int finishes;
    float karma;

    int64 lbRefreshAfter;
    MapLbEntry[] lbEntries;
    MapLbEntry@ myLbEntry;

    bool isRefreshing;

    MapInfo() {}

    MapInfo(const string &in uid) {
        this.uid = uid;
    }

    // from list describing map
    // ["Kacky Reloaded #301", "$<$aa0$i$oKack$>$<$05a$i$oy Re$>$<$09a$i$olo$>$<$6a0$i$oad$>$<$aa0$i$oed $>$<$4f0$i$o#301$>", "12tr_2vNsjH1_F_xJQIkS_YB2hc",
    // " /\\dralonter",
    // "$<$000 /\\dralonter$>", "00:19.589", "lego piece 53119", "lego piece 53119", 5, 100.0]
    MapInfo(Json::Value@ j, int ix) {
        this.FromJson(j, ix);
    }

    void FromJson(Json::Value@ j, int ix) {
        this.mapIx = ix;
        this.name = j[0];
        this.nameFmt = Text::OpenplanetFormatCodes(j[1]);
        this.uid = j[2];
        this.author = j[3];
        this.authorFmt = Text::OpenplanetFormatCodes(j[4]);
        this.wrTimeStr = j[5];
        this.wrHolder = j[6];
        this.wrHolderFmt = Text::OpenplanetFormatCodes(j[7]);
        this.finishes = int(j[8]);
        this.karma = float(j[9]);
    }

    void LoadMapLbAsync() {
        isRefreshing = true;
        auto j = MapMonitor::GetKR5Map(mapIx);
        lbRefreshAfter = int64(j["ts"]) + int(j["min_refresh_period"]);
        if (lbRefreshAfter < Time::Stamp + 120) lbRefreshAfter = Time::Stamp + 120;
        auto lb = j["lb"];
        lbEntries.Resize(lb.Length);
        for (uint i = 0; i < lb.Length; i++) {
            auto @lbEntry = lbEntries[i];
            lbEntry.FromJson(lb[i]);
            if (lbEntry.name == S_PlayerName) {
                @this.myLbEntry = lbEntry;
            }
            CheckPause();
        }
        isRefreshing = false;
    }

    void CheckMyRecord() {
        @this.myLbEntry = null;
        for (uint i = 0; i < lbEntries.Length; i++) {
            if (lbEntries[i].name == S_PlayerName) {
                @this.myLbEntry = lbEntries[i];
                break;
            }
        }
    }

    void UpdateTimeStrs() {
        // wrTimeStr = Time::Format(wrTime, true, false);
        // pbTimeStr = Time::Format(pbTime, true, false);
        // avgTimeStr = Time::Format(averageTime, true, false);
        // worstTimeStr = Time::Format(worstTime, true, false);
    }

    // Update PB position, time, etc
    void RunUpdatePbEtc() {
        // get values
        UpdateTimeStrs();
    }

    void TestingPopulateRandomly() {
        // this.myPos = Math::Rand(1, 100);
        // this.lbLength = Math::Rand(100, 1000);
        // this.wrTime = Math::Rand(1000, 30000);
        // this.averageTime = Math::Rand(wrTime, 100000);
        // this.pbTime = Math::Rand(wrTime, 100000);
        // this.worstTime = Math::Rand(averageTime, 7200000);
        // UpdateTimeStrs();
    }

    float col2Start;
    float col3Start;

    void RenderInMapUI(UI::Font@ font) {
        UI::PushFont(font);

        // space between columns
        auto colPadding = UI::GetScale() * UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x * 1.2;
        // size of string "Last"
        auto lastSize = Draw::MeasureString("Last", font, font.FontSize);
        // start of the second column
        col2Start = lastSize.x + colPadding;
        // start of the third column
        col3Start = col2Start + Draw::MeasureString(worstTimeStr, font, font.FontSize).x + colPadding;

        // make sure we have enough h space
        auto pos = UI::GetCursorPos();
        auto minWidth = S_InMap_ShowRelativeCol ? col3Start : col2Start;
        UI::Dummy(vec2(minWidth + 1, 1));
        UI::SetCursorPos(pos);

        // WR, xx:yy.zzz, +1:23.456
        // Avg, xx:yy.zzz, +1:23.456
        // PB, xx:yy.zzz
        // Last, xx:yy.zzz, -1:23.456
        // Icons::Users 1234


        if (S_InMap_ShowMapName) DrawRow("Map", nameFmt);
        DrawRow("WR", wrTimeStr + (S_InMap_ShowWRHolderName ? " \\$<\\$bbb\\$i by\\$>  " + wrHolderFmt : ""));
        // if (S_InMap_ShowWRHolderName) {
        //     DrawRow("", wrHolderFmt);
        // }
        DrawRow(Icons::Users, tostring(finishes));

        if (myLbEntry !is null) {
            DrawRow("PB", myLbEntry.timeStr + " \\$999 #" + myLbEntry.rank + " \\$<\\$aaa|\\$> " + myLbEntry.finishes + " fin");
        }


        if (isRefreshing) {
            UI::Text("\\$iLoading...");
        }


        // DrawRow("Avg", avgTimeStr, pbTime > 0 ? FmtTimeMbNegative(pbTime - averageTime, true) : "\\$666---");
        // DrawRow("PB", pbTimeStr);
        // DrawRow(Icons::Users, tostring(lbLength));
        // DrawRow("Last", worstTimeStr, pbTime > 0 ? FmtTimeMbNegative(pbTime - worstTime, true) : "\\$666---");

        UI::PopFont();
    }

    void DrawRow(const string &in label, const string &in value, const string &in diff = "") {
        auto pos = UI::GetCursorPos();
        UI::Text(label);
        UI::SetCursorPos(pos + vec2(col2Start, 0));
        UI::Text(value);
        if (diff != "" && S_InMap_ShowRelativeCol) {
            UI::SetCursorPos(pos + vec2(col3Start, 0));
            UI::Text(diff);
        }
    }
}

string FmtTimeMbNegative(int time, bool color = false) {
    string col = color ? (time < 0 ? Text::FormatOpenplanetColor(S_RelativeAheadColor) : Text::FormatOpenplanetColor(S_RelativeBehindColor)) : "";
    if (time < 0) {

        return col + "-" + Time::Format(-time, true, false);
    }
    return col + "+" + Time::Format(time, true, false);
}

class MapLbEntry {
    int rank;
    string name;
    string nameFmt;
    string timeStr;
    int finishes;

    MapLbEntry() {}

    MapLbEntry(Json::Value@ j) {
        this.FromJson(j);
    }

    void FromJson(Json::Value@ j) {
        this.rank = int(j[0]);
        this.name = j[1];
        this.nameFmt = Text::OpenplanetFormatCodes(j[2]);
        this.timeStr = j[3];
        this.finishes = int(j[4]);
    }
}
