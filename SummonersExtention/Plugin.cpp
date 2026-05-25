// This file added in headers queue

// File: "Sources.h"

#include "resource.h"



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



  // NB sometimes resets summon cap; restore from SE_PersistSummonMax (set in .d on learn).

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



  static void SE_ReapplyPersistMana() {

    if (!parser) {

      return;

    }

    const int floor = SE_ReadIntSymbol("SE_PersistGodGiftMana", 0);

    if (floor <= 0) {

      return;

    }

    const int godGiftMana = SE_ReadIntSymbol("RX_GodGiftMana", 0);

    if (godGiftMana >= 0 && godGiftMana < floor) {

      SE_WriteIntSymbol("RX_GodGiftMana", floor);

    }

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

      SE_ReapplyPersistMana();

    }

  }



  void Game_PostLoop() {

  }



  void Game_MenuLoop() {

  }



  TSaveLoadGameInfo& SaveLoadGameInfo = UnionCore::SaveLoadGameInfo;



  void Game_SaveBegin() {

  }



  void Game_SaveEnd() {

  }



  void LoadBegin() {

  }



  void LoadEnd() {

    SE_ReapplyPersistCap();

    SE_ReapplyPersistMana();

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



  void Game_ApplyOptions() {

  }



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

    Enabled( AppDefault ) Game_ApplyOptions

  );

}

