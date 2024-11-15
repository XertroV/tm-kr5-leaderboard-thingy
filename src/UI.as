const int INMAP_WINDOW_FLAGS = UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar;

UI::Font@ g_Font16; // = UI::LoadFont("DroidSans.ttf", 16.0);
UI::Font@ g_Font20; // = UI::LoadFont("DroidSans.ttf", 20.0);
UI::Font@ g_Font26; // = UI::LoadFont("DroidSans.ttf", 26.0);
UI::Font@ g_FontBold; // = UI::LoadFont("DroidSans-Bold.ttf", 16.0);
UI::Font@ g_FontMono; // = UI::LoadFont("DroidSansMono.ttf", 16.0);

void LoadFonts() {
    @g_Font16 = UI::LoadFont("DroidSans.ttf", 16.0, -1, -1, true, true, true);
    @g_Font20 = UI::LoadFont("DroidSans.ttf", 20.0, -1, -1, true, true, true);
    @g_Font26 = UI::LoadFont("DroidSans.ttf", 26.0, -1, -1, true, true, true);
    @g_FontBold = UI::LoadFont("DroidSans-Bold.ttf", 16.0, -1, -1, true, true, true);
    @g_FontMono = UI::LoadFont("DroidSansMono.ttf", 16.0, -1, -1, true, true, true);
}

enum FontChoice {
    DroidSans16,
    DroidSans20,
    DroidSans26,
    DroidSansBold16,
    DroidSansMono16
}

UI::Font@ GetFont(FontChoice choice) {
    switch (choice) {
        case FontChoice::DroidSans16: return g_Font16;
        case FontChoice::DroidSans20: return g_Font20;
        case FontChoice::DroidSans26: return g_Font26;
        case FontChoice::DroidSansBold16: return g_FontBold;
        case FontChoice::DroidSansMono16: return g_FontMono;
    }
    return g_Font16;
}

void DrawFontComboChoice() {
    if (UI::BeginCombo("Font", tostring(S_InMap_FontChoice))) {
        if (UI::Selectable("Droid Sans 16", S_InMap_FontChoice == FontChoice::DroidSans16)) {
            S_InMap_FontChoice = FontChoice::DroidSans16;
        }
        if (UI::Selectable("Droid Sans 20", S_InMap_FontChoice == FontChoice::DroidSans20)) {
            S_InMap_FontChoice = FontChoice::DroidSans20;
        }
        if (UI::Selectable("Droid Sans 26", S_InMap_FontChoice == FontChoice::DroidSans26)) {
            S_InMap_FontChoice = FontChoice::DroidSans26;
        }
        if (UI::Selectable("Droid Sans Bold 16", S_InMap_FontChoice == FontChoice::DroidSansBold16)) {
            S_InMap_FontChoice = FontChoice::DroidSansBold16;
        }
        if (UI::Selectable("Droid Sans Mono 16", S_InMap_FontChoice == FontChoice::DroidSansMono16)) {
            S_InMap_FontChoice = FontChoice::DroidSansMono16;
        }
        UI::EndCombo();
    }
}

void Render() {
    if (g_Font16 is null) return;
    if (g_MapCollection is null) return;
    if (!UI::IsOverlayShown() && !S_RenderWhileOpenplanetUIHidden) return;
    if (!ShouldRenderGenerally()) return;
    if (UI::Begin("cLBs", INMAP_WINDOW_FLAGS)) {
        RenderMapWindowInner(GetFont(S_InMap_FontChoice));
    }
    UI::End();
}

[Setting hidden]
bool g_ShowMainWindow = false;

void RenderInterface() {
    if (g_ShowMainWindow) {
        Render_MainWindow();
    }
}

/** Render function called every frame intended only for menu items in `UI`.
*/
void RenderMenu() {
    if (UI::MenuItem("KR5 Thingy: Big Window", "", g_ShowMainWindow)) {
        g_ShowMainWindow = !g_ShowMainWindow;
    }
}

// for rendering in-map ui
bool ShouldRenderGenerally() {
    // for testing
    // return true;
    // actual function
    if (!UI::IsGameUIVisible() && !S_RenderWhileGameUIHidden) return false;
    if (lastMapIdV == 0) return false;
    return f_IsMapInCollection;
}

void RenderMapWindowInner(UI::Font@ font) {
    vec2 initCursorPos = UI::GetCursorPos();
    vec2 crAvail = UI::GetContentRegionAvail();

    vec2 windowPos = UI::GetWindowPos();

    vec2 windowSize = UI::GetWindowSize();
    vec2 cursorPos = UI::GetMousePos() - windowPos;
    bool outsideWindow = cursorPos.x < 0 || cursorPos.y < 0 || cursorPos.x > windowSize.x || cursorPos.y > windowSize.y;
    bool rightClickedWindow = !outsideWindow && UI::IsMouseClicked(UI::MouseButton::Right);
    if (rightClickedWindow) {
        // trace("right clicked window");
        UI::OpenPopup("cLBsMenu");
    }

    UI::PushFont(font);
    if (g_CurrMap is null) {
        UI::Text("No map");
        UI::Text("Mouse: " + cursorPos.x + ", " + cursorPos.y);
    } else {
        g_CurrMap.RenderInMapUI(font);
    }
    UI::PopFont();

    DrawRightClickMenu();
}

void RunRefresh() {
    g_CurrMap.LoadMapLbAsync();
    g_MapCollection.LoadMapsAsync();
}

void DrawRightClickMenu() {
    if (UI::BeginPopup("cLBsMenu")) {
        UI::SeparatorText("Helpers");

        if (UI::Button("Refresh")) {
            // todo: run refresh
            startnew(RunRefresh);
            UI::CloseCurrentPopup();
        }

        if (UI::Button("Show Big Window")) {
            g_ShowMainWindow = true;
            UI::ShowOverlay();
            UI::CloseCurrentPopup();
        }

        UI::SeparatorText("Settings");

        DrawFontComboChoice();

        if (UI::MenuItem("Show Map Name", "", S_InMap_ShowMapName)) {
            S_InMap_ShowMapName = !S_InMap_ShowMapName;
            UI::CloseCurrentPopup();
        }

        if (UI::MenuItem("Show WR Holder Name", "", S_InMap_ShowWRHolderName)) {
            S_InMap_ShowWRHolderName = !S_InMap_ShowWRHolderName;
            UI::CloseCurrentPopup();
        }

        if (UI::MenuItem("Show PB Gap to WR", "", S_InMap_ShowGapToWR)) {
            S_InMap_ShowGapToWR = !S_InMap_ShowGapToWR;
            UI::CloseCurrentPopup();
        }

        if (UI::MenuItem("Show Number of Finishers", "", S_InMap_ShowNbFinishers)) {
            S_InMap_ShowNbFinishers = !S_InMap_ShowNbFinishers;
            UI::CloseCurrentPopup();
        }

        if (UI::MenuItem("Apply Font to Big Window", "", S_ApplyFontBigWindow)) {
            S_ApplyFontBigWindow = !S_ApplyFontBigWindow;
            UI::CloseCurrentPopup();
        }

        // if (UI::MenuItem("Show Comparisons to PB", "", S_InMap_ShowRelativeCol)) {
        //     S_InMap_ShowRelativeCol = !S_InMap_ShowRelativeCol;
        //     UI::CloseCurrentPopup();
        // }

        UI::EndPopup();
    }
}



void Render_MainWindow() {
    // UI::WindowFlags::NoCollapse
    UI::SetNextWindowSize(700, 500, UI::Cond::Appearing);
    UI::PushFont(S_ApplyFontBigWindow ? GetFont(S_InMap_FontChoice) : g_Font16);
    if (UI::Begin("KR5 Ranking Thingy", g_ShowMainWindow)) {
        UI::BeginTabBar("kr5tabs");

        if (UI::BeginTabItem("Maps")) {
            if (UI::BeginChild("maps")) {
                Draw_MapsTab();
            }
            UI::EndChild();
            UI::EndTabItem();
        }

        if (UI::BeginTabItem("Ranking")) {
            if (UI::BeginChild("res")) {
                Draw_ResultsTab();
            }
            UI::EndChild();
            UI::EndTabItem();
        }

        if (UI::BeginTabItem("Profile")) {
            if (UI::BeginChild("profile")) {
                Render_ST_Profile();
            }
            UI::EndChild();
            UI::EndTabItem();
        }

        UI::EndTabBar();
    }
    UI::End();
    UI::PopFont();
}


void Draw_MapsTab() {
    if (UI::Button("Refresh")) {
        startnew(CoroutineFunc(g_MapCollection.LoadMapsAsync));
    }

    if (g_MapCollection.isRefreshing) {
        UI::Text("Loading...");
        return;
    }

    UI::SameLine();
    if (g_MapCollection.mapsRefreshAfter < Time::Stamp) {
        UI::Text("\\$888\\$iData is stale (updated every 5 minutes)");
    } else {
        UI::Text("\\$888\\$iCan refresh in " + Time::Format((g_MapCollection.mapsRefreshAfter - Time::Stamp) * 1000, false, true));
    }

    auto @maps = g_MapCollection.mapInfos;
    if (maps.Length == 0) {
        UI::Text("No maps");
        return;
    }

    UI::BeginTable("maps", 8, UI::TableFlags::SizingFixedFit | UI::TableFlags::RowBg);
    PushTableStyles();

    UI::TableSetupColumn("Name");
    UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthStretch);
    UI::TableSetupColumn("WR (Time)");
    UI::TableSetupColumn("WR (Holder)", UI::TableColumnFlags::WidthStretch);
    UI::TableSetupColumn("PB (Time)");
    UI::TableSetupColumn("PB (Rank)");
    UI::TableSetupColumn("Finishes");
    UI::TableSetupColumn("Karma");
    UI::TableHeadersRow();

    UI::ListClipper clip(maps.Length);
    while (clip.Step()) {
        for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
            MapInfo@ map = maps[i];
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(map.nameFmt);
            UI::TableNextColumn();
            UI::Text(map.authorFmt);
            UI::TableNextColumn();
            UI::Text(map.wrTimeStr);
            UI::TableNextColumn();
            UI::Text(map.wrHolderFmt);
            UI::TableNextColumn();
            UI::Text(map.myLbEntry !is null ? map.myLbEntry.timeStr : "");
            UI::TableNextColumn();
            UI::Text(map.myLbEntry !is null ? tostring(map.myLbEntry.rank) : "");
            UI::TableNextColumn();
            UI::Text(tostring(map.finishes));
            UI::TableNextColumn();
            UI::Text(tostring(map.karma));
        }
    }

    PopTableStyles();
    UI::EndTable();
}


void Draw_ResultsTab() {
    if (UI::Button("Refresh")) {
        startnew(CoroutineFunc(g_MapCollection.LoadResultsAsync));
    }

    if (g_MapCollection.isRefreshing) {
        UI::Text("Loading...");
        return;
    }

    UI::SameLine();
    if (g_MapCollection.resultsRefreshAfter < Time::Stamp) {
        UI::Text("\\$888\\$iData is stale (updated every 5 minutes)");
    } else {
        UI::Text("\\$888\\$iCan refresh in " + Time::Format((g_MapCollection.resultsRefreshAfter - Time::Stamp) * 1000, false, true));
    }

    auto @results = g_MapCollection.lb;
    if (results.Length == 0) {
        UI::Text("No results");
        return;
    }

    UI::BeginTable("results", 5, UI::TableFlags::SizingFixedFit | UI::TableFlags::RowBg);
    PushTableStyles();

    UI::TableSetupColumn("Rank");
    UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
    UI::TableSetupColumn("Finishes");
    UI::TableSetupColumn("Average (Over All)");
    UI::TableSetupColumn("Average (Finished)");
    UI::TableHeadersRow();

    UI::ListClipper clip(results.Length);
    while (clip.Step()) {
        for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
            MainResultsEntry@ res = results[i];
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(tostring(res.rank));
            UI::TableNextColumn();
            UI::Text(res.nameFmt);
            UI::TableNextColumn();
            UI::Text(tostring(res.finishes));
            UI::TableNextColumn();
            UI::Text(tostring(res.average));
            UI::TableNextColumn();
            UI::Text(tostring(res.averageFinished));
        }
    }

    PopTableStyles();
    UI::EndTable();
}


void PushTableStyles() {
    UI::PushStyleColor(UI::Col::TableRowBg, vec4(0.3, 0.3, 0.3, .5));
    UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.4, 0.4, 0.4, .5));
}

void PopTableStyles() {
    UI::PopStyleColor(2);
}
