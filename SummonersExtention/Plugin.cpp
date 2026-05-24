// This file added in headers queue
// File: "Sources.h"
#include "resource.h"
#include <stdio.h>

namespace GOTHIC_ENGINE {

  static int SE_ReadIntSymbol(const char* name, int stackPos = 0) {
    if (!parser) {
      return -1;
    }
    zCPar_Symbol* sym = parser->GetSymbol(zSTRING(name));
    if (!sym) {
      return -1;
    }
    int val = 0;
    sym->GetValue(val, stackPos);
    return val;
  }

  static void SE_WriteIntSymbol(const char* name, int val) {
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

  static int SE_ReadSummonMax() {
    return SE_ReadIntSymbol("RX_SummonCountMax", 0);
  }

  static int SE_ReadGodGiftSummonMax() {
    return SE_ReadIntSymbol("RX_GodGiftSummonMax", 0);
  }

  static int SE_ReadRxSummonMaxConst() {
    return SE_ReadIntSymbol("RX_SUMMONMAX", 0);
  }

  static void SE_WriteSummonCapFloor(int floor) {
    if (floor <= 0) {
      return;
    }
    SE_WriteIntSymbol("RX_SummonCountMax", floor);
    SE_WriteIntSymbol("RX_GodGiftSummonMax", floor);
    SE_WriteIntSymbol("RX_SUMMONMAX", floor);
  }

  static void SE_ReapplyPersistCap() {
    if (!parser) {
      return;
    }
    const int floor = SE_ReadIntSymbol("SE_PersistSummonMax", 0);
    if (floor <= 0) {
      return;
    }
    const int countMax = SE_ReadSummonMax();
    const int godGift = SE_ReadGodGiftSummonMax();
    const int rxMax = SE_ReadRxSummonMaxConst();
    if (countMax < floor || godGift < floor || (rxMax >= 0 && rxMax < floor)) {
      SE_WriteSummonCapFloor(floor);
    }
  }

  static int SE_BumpPersistCap() {
    int cur = SE_ReadSummonMax();
    const int godGift = SE_ReadGodGiftSummonMax();
    const int rxMax = SE_ReadRxSummonMaxConst();
    if (godGift > cur) {
      cur = godGift;
    }
    if (rxMax > cur) {
      cur = rxMax;
    }
    cur += 1;
    SE_WriteIntSymbol("SE_PersistSummonMax", cur);
    SE_WriteSummonCapFloor(cur);
    return cur;
  }

  int __cdecl SE_IncSummonMax_External() {
    const int floor = SE_BumpPersistCap();
    parser->SetReturn(floor);
    return floor;
  }

  void Game_Entry() {
  }
  
  void Game_Init() {
  }

  void Game_Exit() {
  }

  void Game_PreLoop() {
  }

  void Game_Loop() {
    if (!parser) {
      return;
    }
    static int reapplyTick = 0;
    if (++reapplyTick >= 20) {
      reapplyTick = 0;
      SE_ReapplyPersistCap();
    }
    if (zKeyToggled(KEY_F9)) {
      int maxBefore = SE_ReadSummonMax();
      int giftBefore = SE_ReadGodGiftSummonMax();
      int rxMaxBefore = SE_ReadRxSummonMaxConst();
      int cur = SE_ReadIntSymbol("RX_SummonCount", 0);
      const int ret = SE_IncSummonMax_External();
      int maxAfter = SE_ReadSummonMax();
      int giftAfter = SE_ReadGodGiftSummonMax();
      int rxMaxAfter = SE_ReadRxSummonMaxConst();
      char msg[256];
      sprintf_s(
        msg,
        "cur=%d floor=%d\nCountMax: %d->%d\nGodGift: %d->%d\nRX_SUMMONMAX: %d->%d",
        cur,
        ret,
        maxBefore,
        maxAfter,
        giftBefore,
        giftAfter,
        rxMaxBefore,
        rxMaxAfter);
      Message::Info(msg, "SummonersExtention (F9=+1 F10=reset)");
    }
  }

  void Game_PostLoop() {
  }

  void Game_MenuLoop() {
  }

  // Information about current saving or loading world
  TSaveLoadGameInfo& SaveLoadGameInfo = UnionCore::SaveLoadGameInfo;

  void Game_SaveBegin() {
  }

  void Game_SaveEnd() {
  }

  void LoadBegin() {
  }

  void LoadEnd() {
    SE_ReapplyPersistCap();
  }

  void Game_LoadBegin_NewGame() {
    LoadBegin();
  }

  void Game_LoadEnd_NewGame() {
    LoadEnd();
  }

  void Game_LoadBegin_SaveGame() {
    LoadBegin();
  }

  void Game_LoadEnd_SaveGame() {
    LoadEnd();
  }

  void Game_LoadBegin_ChangeLevel() {
    LoadBegin();
  }

  void Game_LoadEnd_ChangeLevel() {
    LoadEnd();
  }

  void Game_LoadBegin_Trigger() {
  }
  
  void Game_LoadEnd_Trigger() {
  }
  
  void Game_Pause() {
  }
  
  void Game_Unpause() {
  }
  
  void Game_DefineExternals() {
    parser->DefineExternal("SE_IncSummonMax", SE_IncSummonMax_External, zPAR_TYPE_INT, zPAR_TYPE_VOID);
  }

  void Game_ApplyOptions() {
  }

  /*
  Functions call order on Game initialization:
    - Game_Entry           * Gothic entry point
    - Game_DefineExternals * Define external script functions
    - Game_Init            * After DAT files init
  
  Functions call order on Change level:
    - Game_LoadBegin_Trigger     * Entry in trigger
    - Game_LoadEnd_Trigger       *
    - Game_Loop                  * Frame call window
    - Game_LoadBegin_ChangeLevel * Load begin
    - Game_SaveBegin             * Save previous level information
    - Game_SaveEnd               *
    - Game_LoadEnd_ChangeLevel   *
  
  Functions call order on Save game:
    - Game_Pause     * Open menu
    - Game_Unpause   * Click on save
    - Game_Loop      * Frame call window
    - Game_SaveBegin * Save begin
    - Game_SaveEnd   *
  
  Functions call order on Load game:
    - Game_Pause              * Open menu
    - Game_Unpause            * Click on load
    - Game_LoadBegin_SaveGame * Load begin
    - Game_LoadEnd_SaveGame   *
  */

#define AppDefault True
  CApplication* lpApplication = !CHECK_THIS_ENGINE ? Null : CApplication::CreateRefApplication(
    Enabled( AppDefault ) Game_Entry,
    Enabled( AppDefault ) Game_Init,
    Enabled( AppDefault ) Game_Exit,
    Enabled( AppDefault ) Game_PreLoop,
    Enabled( AppDefault ) Game_Loop,
    Enabled( AppDefault ) Game_PostLoop,
    Enabled( AppDefault ) Game_MenuLoop,
    Enabled( AppDefault ) Game_SaveBegin,
    Enabled( AppDefault ) Game_SaveEnd,
    Enabled( AppDefault ) Game_LoadBegin_NewGame,
    Enabled( AppDefault ) Game_LoadEnd_NewGame,
    Enabled( AppDefault ) Game_LoadBegin_SaveGame,
    Enabled( AppDefault ) Game_LoadEnd_SaveGame,
    Enabled( AppDefault ) Game_LoadBegin_ChangeLevel,
    Enabled( AppDefault ) Game_LoadEnd_ChangeLevel,
    Enabled( AppDefault ) Game_LoadBegin_Trigger,
    Enabled( AppDefault ) Game_LoadEnd_Trigger,
    Enabled( AppDefault ) Game_Pause,
    Enabled( AppDefault ) Game_Unpause,
    Enabled( AppDefault ) Game_DefineExternals,
    Enabled( AppDefault ) Game_ApplyOptions
  );
}
