[Setting category="Visibility" name="Show when Overlay (F3) hidden"]
bool S_RenderWhileOpenplanetUIHidden = true;

[Setting category="Visibility" name="Show when Game UI hidden"]
bool S_RenderWhileGameUIHidden = true;


[Setting category="In-Map UI" name="Show In-Map UI"]
bool S_ShowInMapUI = true;

// [Setting category="In-Map UI" name="Show Comparisons to PB (for WR, Avg, and Last)"]
bool S_InMap_ShowRelativeCol = false;

[Setting category="In-Map UI" name="Show Map Name"]
bool S_InMap_ShowMapName = true;

[Setting category="In-Map UI" name="Show WR Holder Name"]
bool S_InMap_ShowWRHolderName = true;

[Setting category="In-Map UI" name="Font Choice"]
FontChoice S_InMap_FontChoice = FontChoice::DroidSans16;

[Setting category="Big Window" name="Apply In-Map Font to Big Window"]
bool S_ApplyFontBigWindow = true;

// [Setting category="Colors" name="Relative: Ahead"]
vec3 S_RelativeAheadColor = vec3(0.0, 1.0, 0.0);

// [Setting category="Colors" name="Relative: Behind"]
vec3 S_RelativeBehindColor = vec3(1.0, 0.0, 0.0);

[Setting category="Logs" name="Extra logging (requests mostly)"]
bool S_ExtraLogging = false;

// [Setting category="Profile" name="Player Name"]
[Setting hidden]
string S_PlayerName = "";

[SettingsTab name="Profile"]
void Render_ST_Profile() {
    UI::Text("Player Name: " + (S_PlayerName.Length > 0 ? S_PlayerName : "\\$aaa\\$iNot set"));
    UI::SeparatorText("Players");

    UI::BeginTable("plrs", 3, UI::TableFlags::SizingStretchSame | UI::TableFlags::RowBg);
    PushTableStyles();

    UI::TableSetupColumn("Rank");
    UI::TableSetupColumn("Name");
    UI::TableSetupColumn("Button");

    UI::ListClipper clip(g_MapCollection.lb.Length);

    while (clip.Step()) {
        for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
            MainResultsEntry@ lb = g_MapCollection.lb[i];
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(tostring(lb.rank) + ".");
            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(lb.nameFmt);
            UI::TableNextColumn();
            if (UI::Button("Set as Me##" + i)) {
                S_PlayerName = lb.name;
                g_MapCollection.OnPlayerNameChange();
            }
        }
    }

    PopTableStyles();
    UI::EndTable();
}
