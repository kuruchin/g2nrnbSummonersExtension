// Included only from Interface.cpp (#ifdef __G2A) after Headers.h — do not compile as .cpp
// Summon HP bars: StExt/EB pattern (oCViewStatusBar on screen), one tick in B_UPDATESTAMINABAR.

#include <cstring>

namespace Gothic_II_Addon {

  static const char* SE_IniSection = "AST";
  static const char* SE_IniShowBar = "bShowSummonHealthBar";
  static const char* SE_IniBarPosX = "bShowSummonHealthBarPosX";
  static const char* SE_IniBarPosY = "bShowSummonHealthBarPosY";

  static const int SE_BAR_SLOT_MAX = 12;
  static const int SE_BAR_STACK_GAP = 22;
  static const int SE_BAR_JINA_SLOT_GAP = 22;
  static const int SE_BAR_DEFAULT_POS_X = 200;

  static oCViewStatusBar* SE_NativeBars[SE_BAR_SLOT_MAX] = {};
  static int SE_NativeBarW = 0;
  static int SE_NativeBarH = 0;
  static bool SE_HudDrawnThisFrame = false;

  static int SE_BarReadIntSymbol(const char* name) {
    if (!parser) {
      return -1;
    }
    zCPar_Symbol* sym = parser->GetSymbol(zSTRING(name));
    if (!sym) {
      return -1;
    }
    int val = 0;
    sym->GetValue(val, 0);
    return val;
  }

  static void SE_BarWriteIntSymbol(const char* name, int val) {
    if (!parser) {
      return;
    }
    zCPar_Symbol* sym = parser->GetSymbol(zSTRING(name));
    if (!sym) {
      return;
    }
    sym->SetValue(val, 0);
    void* adr = sym->GetDataAdr(0);
    if (adr) {
      *static_cast<int*>(adr) = val;
    }
  }

  static bool SE_EbCanDraw() {
    return screen && ogame && player && ogame->hpBar;
  }

  static bool SE_CanDrawSummonHud() {
    if (!SE_EbCanDraw() || !parser) {
      return false;
    }
    if (ogame->inLevelChange || ogame->inLoadSaveGame) {
      return false;
    }
    if (!ogame->GetGameWorld()) {
      return false;
    }
    if (!ogame->GetShowPlayerStatus()) {
      return false;
    }
    return true;
  }

  static int SE_ReadBarPosX() {
    if (zoptions) {
      return zoptions->ReadInt(zSTRING(SE_IniSection), zSTRING(SE_IniBarPosX), -1);
    }
    return -1;
  }

  static int SE_ReadBarPosY() {
    if (zoptions) {
      return zoptions->ReadInt(zSTRING(SE_IniSection), zSTRING(SE_IniBarPosY), 540);
    }
    return SE_BarReadIntSymbol("SE_SummonBarPosY");
  }

  static int SE_ResolveBarPosX() {
    const int iniX = SE_ReadBarPosX();
    if (iniX >= 0) {
      return iniX;
    }
    return SE_BAR_DEFAULT_POS_X;
  }

  static void SE_GetPetBarAnchor(int& outX, int& outY, int& outW, int& outH) {
    outX = SE_ResolveBarPosX();
    outY = SE_ReadBarPosY();
    outW = 400;
    outH = 25;
    if (ogame && ogame->hpBar) {
      int refW = 0;
      int refH = 0;
      ogame->hpBar->GetSize(refW, refH);
      if (refW > 0) {
        outW = refW;
      }
      if (refH > 0) {
        outH = refH;
      }
    }
    SE_NativeBarW = outW;
    SE_NativeBarH = outH;
  }

  static void SE_EbHideBar(oCViewStatusBar* bar) {
    if (screen && bar) {
      screen->RemoveItem(bar);
    }
  }

  static void SE_ApplySummonBarTextures(oCViewStatusBar* bar) {
    if (!bar) {
      return;
    }
    bar->SetTextures(
      zSTRING("BAR_BACK.TGA"),
      zSTRING("BAR_TEMPMAX.TGA"),
      zSTRING("BAR_STAMINA.TGA"),
      zSTRING("BAR_EMPTY.TGA")
    );
    bar->scale = 1.0f;
  }

  static void SE_EbInitBar(oCViewStatusBar*& bar) {
    if (!screen) {
      return;
    }
    if (bar) {
      screen->RemoveItem(bar);
      delete bar;
      bar = nullptr;
    }
    bar = new oCViewStatusBar();
    bar->Init(5, 5, 1.0f);
    bar->SetMaxRange(0.0f, 100.0f);
    SE_ApplySummonBarTextures(bar);
    screen->InsertItem(bar);
    bar->Render();
  }

  static void SE_EbDrawBarAt(oCViewStatusBar*& bar, int x, int y, int sx, int sy, float cur, float maxVal) {
    if (!SE_EbCanDraw() || maxVal <= 0.0f) {
      SE_EbHideBar(bar);
      return;
    }
    if (!bar) {
      SE_EbInitBar(bar);
    }
    if (!bar) {
      return;
    }
    screen->RemoveItem(bar);
    bar->SetSize(sx, sy);
    bar->SetPos(x, y);
    screen->InsertItem(bar);
    bar->SetMaxRange(0.0f, maxVal);
    bar->SetRange(0.0f, maxVal);
    bar->SetValue(cur);
  }

  static bool SE_IsSummonedGuild(int guild) {
    return guild >= NPC_GIL_SUMMONED_GOBBO_SKELETON && guild <= NPC_GIL_SUMMONED_ZOMBIE;
  }

  static int SE_GetNpcSummonGuild(oCNpc* npc) {
    if (!npc) {
      return -1;
    }
    const int trueGuild = static_cast<int>(npc->guildTrue);
    if (SE_IsSummonedGuild(trueGuild)) {
      return trueGuild;
    }
    return npc->guild;
  }

  static bool SE_InstanceNameStartsWith(oCNpc* npc, const char* prefix) {
    if (!npc || !prefix) {
      return false;
    }
    const char* name = npc->GetInstanceName().ToChar();
    if (!name) {
      return false;
    }
    return std::strncmp(name, prefix, std::strlen(prefix)) == 0;
  }

  static bool SE_InstanceEquals(oCNpc* npc, const char* instanceName) {
    if (!npc || !instanceName) {
      return false;
    }
    return npc->GetInstanceName() == zSTRING(instanceName);
  }

  static bool SE_IsUniquePetNpc(oCNpc* npc) {
    if (!npc) {
      return false;
    }
    if (SE_BarReadIntSymbol("JinaWolfIsUp") && SE_InstanceEquals(npc, "PET_JINA")) {
      return true;
    }
    if (SE_BarReadIntSymbol("CraitIsUp") && SE_InstanceEquals(npc, "CRAIT")) {
      return true;
    }
    if (SE_BarReadIntSymbol("SkeletonUniqIsUp") && SE_InstanceEquals(npc, "SKELETONUNIQ")) {
      return true;
    }
    return false;
  }

  static bool SE_IsNearPlayer(oCNpc* npc) {
    if (!npc || !player) {
      return false;
    }
    return npc->GetDistanceToVob(*player) < 8000.f;
  }

  static bool SE_IsPlayerOwnedSummon(oCNpc* npc) {
    if (!npc || npc == player) {
      return false;
    }
    if (npc->IsDead()) {
      return false;
    }
    if (SE_IsUniquePetNpc(npc)) {
      return false;
    }
    if (!SE_IsNearPlayer(npc)) {
      return false;
    }
    if (SE_InstanceNameStartsWith(npc, "SUMMONED_")) {
      return true;
    }
    if (npc->isSummoned && SE_IsSummonedGuild(SE_GetNpcSummonGuild(npc))) {
      return true;
    }
    return false;
  }

  static void SE_RemoveNativeBarsFromScreen() {
    for (int i = 0; i < SE_BAR_SLOT_MAX; ++i) {
      SE_EbHideBar(SE_NativeBars[i]);
      if (SE_NativeBars[i]) {
        SE_NativeBars[i]->ondesk = false;
      }
    }
  }

  static void SE_SyncSummonBarIniToScript() {
    int show = 1;
    int posY = 540;
    if (zoptions) {
      show = zoptions->ReadInt(zSTRING(SE_IniSection), zSTRING(SE_IniShowBar), 1);
      posY = zoptions->ReadInt(zSTRING(SE_IniSection), zSTRING(SE_IniBarPosY), 540);
    }
    SE_BarWriteIntSymbol("SE_SummonBarShow", show);
    SE_BarWriteIntSymbol("SE_SummonBarPosY", posY);
  }

  static int SE_IsSummonBarEnabled() {
    if (zoptions) {
      return zoptions->ReadInt(zSTRING(SE_IniSection), zSTRING(SE_IniShowBar), 1) != 0;
    }
    return SE_BarReadIntSymbol("SE_SummonBarShow") != 0;
  }

  static void SE_DrawAllBars_Eb() {
    if (!SE_EbCanDraw()) {
      SE_RemoveNativeBarsFromScreen();
      return;
    }

    int sx = 0;
    int sy = 0;
    int anchorX = 0;
    int anchorY = 0;
    SE_GetPetBarAnchor(anchorX, anchorY, sx, sy);

    if (!SE_IsSummonBarEnabled() || !ogame->GetGameWorld()) {
      SE_RemoveNativeBarsFromScreen();
      return;
    }

    oCWorld* world = ogame->GetGameWorld();
    oCNpc* summons[SE_BAR_SLOT_MAX] = {};
    int summonCount = 0;
    int maxSummons = SE_BAR_SLOT_MAX;
    const int rxCount = SE_BarReadIntSymbol("RX_SummonCount");
    if (rxCount > 0 && rxCount < maxSummons) {
      maxSummons = rxCount;
    }

    if (world && world->voblist_npcs) {
      for (zCListSort<oCNpc>* it = world->voblist_npcs; it; it = it->GetNextInList()) {
        oCNpc* npc = it->GetData();
        if (!SE_IsPlayerOwnedSummon(npc)) {
          continue;
        }
        bool duplicate = false;
        for (int k = 0; k < summonCount; ++k) {
          if (summons[k] == npc) {
            duplicate = true;
            break;
          }
        }
        if (duplicate) {
          continue;
        }
        if (summonCount >= maxSummons) {
          break;
        }
        summons[summonCount++] = npc;
      }
    }

    int usedSlot = 0;
    for (int stackIndex = 0; stackIndex < summonCount && usedSlot < SE_BAR_SLOT_MAX; ++stackIndex) {
      oCNpc* npc = summons[stackIndex];
      if (!npc || npc->IsDead()) {
        continue;
      }
      const int hpMax = npc->GetAttribute(NPC_ATR_HITPOINTSMAX);
      if (hpMax <= 0) {
        continue;
      }
      const float hp = static_cast<float>(npc->GetAttribute(NPC_ATR_HITPOINTS));
      const int barX = anchorX;
      const int barY = anchorY + sy + SE_BAR_JINA_SLOT_GAP + stackIndex * (sy + SE_BAR_STACK_GAP);
      SE_EbDrawBarAt(SE_NativeBars[usedSlot], barX, barY, sx, sy, hp, static_cast<float>(hpMax));
      ++usedSlot;
    }

    for (int j = usedSlot; j < SE_BAR_SLOT_MAX; ++j) {
      SE_EbHideBar(SE_NativeBars[j]);
    }
  }

  static void SE_DrawSummonHud_G2A() {
    if (SE_HudDrawnThisFrame) {
      return;
    }
    if (!parser) {
      return;
    }
    if (!SE_CanDrawSummonHud()) {
      return;
    }
    SE_SyncSummonBarIniToScript();
    SE_DrawAllBars_Eb();
    SE_HudDrawnThisFrame = true;
  }

  void SE_BeginHudFrame_G2A() {
    SE_HudDrawnThisFrame = false;
  }

  void __cdecl SE_NativeRunBarHudTick() {
    SE_DrawSummonHud_G2A();
  }

  void SE_ShutdownSummonBars_G2A() {
    SE_RemoveNativeBarsFromScreen();
    for (int i = 0; i < SE_BAR_SLOT_MAX; ++i) {
      if (SE_NativeBars[i]) {
        delete SE_NativeBars[i];
        SE_NativeBars[i] = nullptr;
      }
    }
    SE_NativeBarW = 0;
    SE_NativeBarH = 0;
  }

  void SE_MarkDllLoaded_G2A() {
    SE_BarWriteIntSymbol("SE_DllLoaded", 1);
    SE_SyncSummonBarIniToScript();
  }

  void __cdecl SE_NativeSyncBarIni() {
    SE_SyncSummonBarIniToScript();
  }

  void SE_DefineSummonBarExternals_G2A() {
    if (!parser) {
      return;
    }
    parser->DefineExternal(
      zSTRING("SE_NativeRunBarHudTick"),
      reinterpret_cast<int(__cdecl*)(void)>(SE_NativeRunBarHudTick),
      zPAR_TYPE_VOID,
      zPAR_TYPE_VOID
    );
    parser->DefineExternal(
      zSTRING("SE_NativeSyncBarIni"),
      reinterpret_cast<int(__cdecl*)(void)>(SE_NativeSyncBarIni),
      zPAR_TYPE_VOID,
      zPAR_TYPE_VOID
    );
  }

  HOOK Hook_oCGame_UpdatePlayerStatus PATCH(&oCGame::UpdatePlayerStatus, &oCGame::UpdatePlayerStatus_SE);

  void oCGame::UpdatePlayerStatus_SE() {
    THISCALL(Hook_oCGame_UpdatePlayerStatus)();
    SE_DrawSummonHud_G2A();
  }

}
