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
  static const int SE_SCREEN_VBUFFER = 8192;

  static oCViewStatusBar* SE_NativeBars[SE_BAR_SLOT_MAX] = {};
  static zCView* SE_BarTextLayer = nullptr;
  static int SE_NativeBarW = 0;
  static int SE_NativeBarH = 0;
  static bool SE_HudDrawnThisFrame = false;

  struct SE_UniquePetHudInfo {
    bool active;
    int x;
    int y;
    int w;
    int h;
    int hpCur;
    int hpMax;
    int level;
    int xpPct;
    oCNpc* npc;
  };

  struct SE_BarLabelRect {
    int x;
    int y;
    int w;
    int h;
    int hpCur;
    int hpMax;
  };

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
    if (ogame && ogame->hpBar) {
      bar->SetTextures(
        ogame->hpBar->texView,
        ogame->hpBar->texRange,
        ogame->hpBar->texValue,
        zSTRING("BAR_EMPTY.TGA")
      );
      bar->scale = ogame->hpBar->scale;
      return;
    }
    bar->SetTextures(
      zSTRING("BAR_BACK.TGA"),
      zSTRING("BAR_TEMPMAX.TGA"),
      zSTRING("BAR_HP.TGA"),
      zSTRING("BAR_EMPTY.TGA")
    );
    bar->scale = 1.0f;
  }

  static zSTRING SE_ResolveParserFont(const char* symbolName) {
    if (!parser || !symbolName) {
      return zSTRING();
    }
    zCPar_Symbol* sym = parser->GetSymbol(zSTRING(symbolName));
    if (!sym || !sym->stringdata) {
      return zSTRING();
    }
    return *sym->stringdata;
  }

  static void SE_ApplyBarLabelFont() {
    if (!SE_BarTextLayer) {
      return;
    }
    static zSTRING barLabelFont;
    if (barLabelFont.IsEmpty()) {
      const char* candidates[] = { "font_screensmall", "text_font_10", "font_game" };
      for (int i = 0; i < 3; ++i) {
        barLabelFont = SE_ResolveParserFont(candidates[i]);
        if (!barLabelFont.IsEmpty()) {
          break;
        }
      }
    }
    if (!barLabelFont.IsEmpty()) {
      SE_BarTextLayer->SetFont(barLabelFont);
    }
    SE_BarTextLayer->SetFontColor(zCOLOR(255, 255, 255));
  }

  static void SE_EnsureBarTextLayer() {
    if (SE_BarTextLayer || !screen) {
      return;
    }
    SE_BarTextLayer = new zCView(0, 0, SE_SCREEN_VBUFFER, SE_SCREEN_VBUFFER);
    SE_BarTextLayer->SetSize(SE_SCREEN_VBUFFER, SE_SCREEN_VBUFFER);
    SE_BarTextLayer->SetPos(0, 0);
  }

  static void SE_HideBarTextLayer() {
    if (screen && SE_BarTextLayer) {
      screen->RemoveItem(SE_BarTextLayer);
      SE_BarTextLayer->ClrPrintwin();
    }
  }

  static void SE_DrawBarLabelsOverlay(const SE_UniquePetHudInfo& uniquePet, const SE_BarLabelRect* labels, int labelCount) {
    if (!screen || (!uniquePet.active && labelCount <= 0)) {
      SE_HideBarTextLayer();
      return;
    }
    SE_EnsureBarTextLayer();
    if (!SE_BarTextLayer) {
      return;
    }

    SE_BarTextLayer->ClrPrintwin();
    SE_ApplyBarLabelFont();

    if (uniquePet.active && uniquePet.hpMax > 0) {
      SE_BarTextLayer->SetFontColor(zCOLOR(0, 255, 0));
      zSTRING hpTxt = Z(uniquePet.hpCur) + "/" + Z(uniquePet.hpMax);
      const int hpW = SE_BarTextLayer->FontSize(hpTxt);
      const int textH = SE_BarTextLayer->FontY();
      const int hpX = uniquePet.x + (uniquePet.w - hpW) / 2;
      const int hpY = uniquePet.y + (uniquePet.h - textH) / 2;
      SE_BarTextLayer->Print(hpX, hpY, hpTxt);

      // "12 Ур. 67%" (CP1251-safe "Ур.")
      zSTRING sideTxt = Z(uniquePet.level) + zSTRING(" \xD3\xF0. ") + Z(uniquePet.xpPct) + "%";
      const int sideX = uniquePet.x + uniquePet.w + 12;
      const int sideY = uniquePet.y + (uniquePet.h - textH) / 2;
      SE_BarTextLayer->Print(sideX, sideY, sideTxt);
      SE_BarTextLayer->SetFontColor(zCOLOR(255, 255, 255));
    }

    for (int i = 0; i < labelCount; ++i) {
      const SE_BarLabelRect& rc = labels[i];
      if (rc.hpMax <= 0) {
        continue;
      }
      zSTRING txt = Z(rc.hpCur) + "/" + Z(rc.hpMax);
      const int textW = SE_BarTextLayer->FontSize(txt);
      const int textH = SE_BarTextLayer->FontY();
      const int tx = rc.x + (rc.w - textW) / 2;
      const int ty = rc.y + (rc.h - textH) / 2;
      SE_BarTextLayer->Print(tx, ty, txt);
    }

    screen->RemoveItem(SE_BarTextLayer);
    screen->InsertItem(SE_BarTextLayer);
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
    if (SE_BarReadIntSymbol("RX_DemonHub_Active") && SE_InstanceEquals(npc, "DEMON_KHUBAKSIS")) {
      return true;
    }
    return false;
  }

  static int SE_ClampInt(int v, int lo, int hi) {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
  }

  static bool SE_ReadSymbolNumberByName(const char* name, float& outVal) {
    outVal = 0.0f;
    if (!parser || !name) {
      return false;
    }
    zCPar_Symbol* sym = parser->GetSymbol(zSTRING(name));
    if (!sym) {
      return false;
    }
    if (sym->type == zPAR_TYPE_INT) {
      int v = 0;
      sym->GetValue(v, 0);
      outVal = static_cast<float>(v);
      return true;
    }
    if (sym->type == zPAR_TYPE_FLOAT) {
      float v = 0.0f;
      sym->GetValue(v, 0);
      outVal = v;
      return true;
    }
    return false;
  }

  static bool SE_ReadSymbolIntByName(const char* name, int& outVal) {
    outVal = 0;
    float v = 0.0f;
    if (!SE_ReadSymbolNumberByName(name, v)) {
      return false;
    }
    outVal = static_cast<int>(v);
    return true;
  }

  enum SE_UniquePetExpKind {
    SE_PET_EXP_JINA = 0,
    SE_PET_EXP_CRAIT,
    SE_PET_EXP_SKELETON,
    SE_PET_EXP_DEMONHUB,
    SE_PET_EXP_COUNT
  };

  struct SE_UniquePetExpCfg {
    const char* expCurSym;
    const char* expNextSym;
    const char* floorPersistSym;
    const char* levelPersistSym;
    const char* prevSymCandidates[6];
  };

  struct SE_UniquePetExpTracker {
    int lastLevel;
    float lastExpNext;
    float expFloor;
    bool hasExpFloor;
  };

  static SE_UniquePetExpTracker SE_PetExpTrackers[SE_PET_EXP_COUNT] = {};

  static int SE_ComputeLevelFillPercent(float expCur, float expNext, float expFloor) {
    if (expNext <= expFloor + 0.001f) {
      return 0;
    }
    const float span = expNext - expFloor;
    const float pct = ((expCur - expFloor) * 100.0f) / span;
    return SE_ClampInt(static_cast<int>(pct), 0, 100);
  }

  static bool SE_TryReadExpFloorFromPrevSymbols(const char* const* candidates, float& outFloor) {
    if (!candidates) {
      return false;
    }
    for (int i = 0; candidates[i]; ++i) {
      float v = 0.0f;
      if (SE_ReadSymbolNumberByName(candidates[i], v)) {
        outFloor = v;
        return true;
      }
    }
    return false;
  }

  static void SE_PersistUniquePetExpFloor(const SE_UniquePetExpCfg& cfg, int level, float expFloor) {
    if (!cfg.floorPersistSym || !cfg.levelPersistSym) {
      return;
    }
    SE_BarWriteIntSymbol(cfg.floorPersistSym, static_cast<int>(expFloor));
    SE_BarWriteIntSymbol(cfg.levelPersistSym, level);
  }

  // NB: JINAWOLFEXPLVL / *_NEXT — накопительные пороги; % = (cur - floor) / (next - floor),
  // где floor — порог входа в текущий уровень (после лвлапа = прежний *_NEXT).
  static int SE_GetUniquePetXpFillPct(SE_UniquePetExpKind kind, int level, float expCur, float expNext, const SE_UniquePetExpCfg& cfg) {
    if (expNext <= 0.001f) {
      return 0;
    }

    SE_UniquePetExpTracker& tr = SE_PetExpTrackers[kind];
    float expFloor = 0.0f;
    bool haveFloor = false;

    if (tr.lastLevel >= 0 && level > tr.lastLevel && tr.lastExpNext > 0.001f) {
      expFloor = tr.lastExpNext;
      haveFloor = true;
    } else if (level <= 1) {
      expFloor = 0.0f;
      haveFloor = true;
    } else if (SE_TryReadExpFloorFromPrevSymbols(cfg.prevSymCandidates, expFloor)) {
      haveFloor = true;
    } else {
      const int trackLvl = SE_BarReadIntSymbol(cfg.levelPersistSym);
      const int floorI = SE_BarReadIntSymbol(cfg.floorPersistSym);
      if (trackLvl == level && floorI >= 0) {
        expFloor = static_cast<float>(floorI);
        haveFloor = true;
      } else if (tr.hasExpFloor && tr.lastLevel == level) {
        expFloor = tr.expFloor;
        haveFloor = true;
      }
    }

    if (haveFloor) {
      tr.expFloor = expFloor;
      tr.hasExpFloor = true;
      SE_PersistUniquePetExpFloor(cfg, level, expFloor);
    }

    if (level < tr.lastLevel) {
      tr.hasExpFloor = false;
      tr.expFloor = 0.0f;
      if (level <= 1) {
        SE_PersistUniquePetExpFloor(cfg, level, 0.0f);
      }
    }

    tr.lastLevel = level;
    tr.lastExpNext = expNext;

    if (!haveFloor) {
      return SE_ClampInt(static_cast<int>((expCur * 100.0f) / expNext), 0, 100);
    }
    return SE_ComputeLevelFillPercent(expCur, expNext, expFloor);
  }

  static void SE_GetUniquePetLevelAndXpPct(oCNpc* npc, int& outLevel, int& outPct) {
    outLevel = 0;
    outPct = 0;

    if (!npc) {
      return;
    }

    // NB: уникальные призывы держат уровень и опыт в отдельных скриптовых символах.
    // Эти имена реально присутствуют в `AB_Scripts.vdf` (проверено поиском по VDF).
    const SE_UniquePetExpCfg* petCfg = nullptr;
    SE_UniquePetExpKind petKind = SE_PET_EXP_JINA;

    if (SE_InstanceEquals(npc, "PET_JINA")) {
      static const SE_UniquePetExpCfg cfg = {
        "JINAWOLFEXPLVL", "JINAWOLFEXPLVL_NEXT", "SE_JinaWolfExpFloor", "SE_JinaWolfExpTrackLvl",
        { "JINAWOLFEXPLVL_PREV", "JINAWOLFEXPLVL_LAST", "JINAWOLFEXPLVL_START", "JINAWOLFEXPLVL_MIN", "JINAWOLFEXPLVL_OLD", nullptr }
      };
      petCfg = &cfg;
      petKind = SE_PET_EXP_JINA;
      if (SE_ReadSymbolIntByName("JinaWolfLvl", outLevel)) {
      } else {
        outLevel = npc->level;
      }
    } else if (SE_InstanceEquals(npc, "CRAIT")) {
      static const SE_UniquePetExpCfg cfg = {
        "CRAITEXPLVL", "CRAITEXPLVL_NEXT", "SE_CraitExpFloor", "SE_CraitExpTrackLvl",
        { "CRAITEXPLVL_PREV", "CRAITEXPLVL_LAST", "CRAITEXPLVL_START", "CRAITEXPLVL_MIN", "CRAITEXP", nullptr }
      };
      petCfg = &cfg;
      petKind = SE_PET_EXP_CRAIT;
      if (SE_ReadSymbolIntByName("CraitLVL", outLevel)) {
      } else {
        outLevel = npc->level;
      }
    } else if (SE_InstanceEquals(npc, "SKELETONUNIQ")) {
      static const SE_UniquePetExpCfg cfg = {
        "SKELETONUNIQEXP", "SKELETONUNIQEXP_NEXT", "SE_SkeletonUniqExpFloor", "SE_SkeletonUniqExpTrackLvl",
        { "SKELETONUNIQEXP_PREV", "SKELETONUNIQEXP_LAST", "SKELETONUNIQEXP_START", "SKELETONUNIQEXP_MIN", nullptr }
      };
      petCfg = &cfg;
      petKind = SE_PET_EXP_SKELETON;
      if (SE_ReadSymbolIntByName("SKELETONUNIQLEVEL", outLevel)) {
      } else {
        outLevel = npc->level;
      }
    } else if (SE_InstanceEquals(npc, "DEMON_KHUBAKSIS")) {
      static const SE_UniquePetExpCfg cfg = {
        "RX_DEMONHUB_EXP", "RX_DEMONHUB_EXPNEXT", "SE_DemonHubExpFloor", "SE_DemonHubExpTrackLvl",
        { "RX_DEMONHUB_EXP_PREV", "RX_DemonHub_ExpPrev", "RX_DEMONHUB_EXP_LAST", nullptr, nullptr }
      };
      petCfg = &cfg;
      petKind = SE_PET_EXP_DEMONHUB;
      if (SE_ReadSymbolIntByName("RX_DEMONHUB_LEVEL", outLevel)) {
      } else if (SE_ReadSymbolIntByName("RX_DemonHub_Level", outLevel)) {
      } else {
        outLevel = npc->level;
      }
    }

    if (petCfg) {
      float expCur = 0.0f;
      float expNext = 0.0f;
      bool haveCur = SE_ReadSymbolNumberByName(petCfg->expCurSym, expCur);
      bool haveNext = SE_ReadSymbolNumberByName(petCfg->expNextSym, expNext);
      if (petKind == SE_PET_EXP_DEMONHUB) {
        if (!haveCur) {
          haveCur = SE_ReadSymbolNumberByName("RX_DemonHub_Exp", expCur);
        }
        if (!haveNext) {
          haveNext = SE_ReadSymbolNumberByName("RX_DemonHub_ExpNext", expNext);
        }
      }
      if (haveCur && haveNext) {
        outPct = SE_GetUniquePetXpFillPct(petKind, outLevel, expCur, expNext, *petCfg);
        return;
      }
    }

    outLevel = npc->level;
    outPct = 0;
  }

  static SE_UniquePetHudInfo SE_FindUniquePetHudInfo(int barX, int barY, int barW, int barH) {
    SE_UniquePetHudInfo info = {};
    info.active = false;

    if (!ogame || !ogame->GetGameWorld()) {
      return info;
    }
    oCWorld* world = ogame->GetGameWorld();
    if (!world || !world->voblist_npcs) {
      return info;
    }

    for (zCListSort<oCNpc>* it = world->voblist_npcs; it; it = it->GetNextInList()) {
      oCNpc* npc = it->GetData();
      if (!npc || npc->IsDead()) {
        continue;
      }
      if (!SE_IsUniquePetNpc(npc)) {
        continue;
      }
      if (!player || npc->GetDistanceToVob(*player) >= 8000.f) {
        continue;
      }

      const int hpMax = npc->GetAttribute(NPC_ATR_HITPOINTSMAX);
      if (hpMax <= 0) {
        break;
      }
      const int hpCur = npc->GetAttribute(NPC_ATR_HITPOINTS);

      int level = 0;
      int pct = 0;
      SE_GetUniquePetLevelAndXpPct(npc, level, pct);

      info.active = true;
      info.x = barX;
      info.y = barY;
      info.w = barW;
      info.h = barH;
      info.hpCur = hpCur;
      info.hpMax = hpMax;
      info.level = level;
      info.xpPct = pct;
      info.npc = npc;
      break;
    }

    return info;
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
    SE_HideBarTextLayer();
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
    const SE_UniquePetHudInfo uniquePet = SE_FindUniquePetHudInfo(anchorX, anchorY, sx, sy);

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

    SE_BarLabelRect labels[SE_BAR_SLOT_MAX] = {};
    int labelCount = 0;
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
      if (labelCount < SE_BAR_SLOT_MAX) {
        labels[labelCount].x = barX;
        labels[labelCount].y = barY;
        labels[labelCount].w = sx;
        labels[labelCount].h = sy;
        labels[labelCount].hpCur = static_cast<int>(hp);
        labels[labelCount].hpMax = hpMax;
        ++labelCount;
      }
      ++usedSlot;
    }

    for (int j = usedSlot; j < SE_BAR_SLOT_MAX; ++j) {
      SE_EbHideBar(SE_NativeBars[j]);
    }

    SE_DrawBarLabelsOverlay(uniquePet, labels, labelCount);
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
    if (SE_BarTextLayer) {
      delete SE_BarTextLayer;
      SE_BarTextLayer = nullptr;
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
