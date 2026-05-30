// SummonersExtention - summon limit perks (Gallahad / Taliasan)
// Edit here in UTF-8. Deploy: Scripts\fix_and_deploy.ps1

META
{
    Parser = Game;
    Engine = G2A;
};

var int SE_SummonSlot1Learned;
var int SE_SummonSlot2Learned;
var int SE_JinaFreeSlotLearned;
var int SE_SummonManaLearned;
var int SE_JinaSummonBypass;
var int SE_PersistSummonMax;
var int SE_PersistGodGiftMana;
var int SE_PersistJinaAutoRevive;
var int SE_PersistWolfPackSummon;
var int SE_NecroGallahadRefused;

// Стая волков (руна ItRu_SumWolf): после каста — цепочка призывов ~2 с
var int SE_WolfPackSummonLearned;
var int SE_WolfPackBurstRunning;
// 0 = пауза между призывами прошла, 1 = ждём (C++ GetTickCount, не счётчик RX_CheckLoop)
var int SE_WolfPackBurstDelayTicks;

// Extra summon HP bars (C++ SE_DrawAllBars_Eb in B_UPDATESTAMINABAR)
var int SE_SummonBarShow;
var int SE_SummonBarPosY;
var int SE_DllLoaded;

// Debug: predmet/spell v rukah (SE_DebugPollHeldItems)
var int SE_DebugLastMeleeId;
var int SE_DebugLastRangedId;
var int SE_DebugLastSpellId;
var int SE_DebugDllWarned;

// Порог опыта на начале текущего уровня уника (для % заполнения, сохраняется в сейве)
var int SE_JinaWolfExpFloor;
var int SE_JinaWolfExpTrackLvl;
var int SE_CraitExpFloor;
var int SE_CraitExpTrackLvl;
var int SE_SkeletonUniqExpFloor;
var int SE_SkeletonUniqExpTrackLvl;
var int SE_DemonHubExpFloor;
var int SE_DemonHubExpTrackLvl;

// Джина: автопризыв (Revive.d) + таймер (JinaCdTimer.d)
var int SE_JinaAutoReviveLearned;
var int SE_JinaReviveEverSummoned;
var int SE_JinaReviveReady;
var int SE_JinaWasAlive;
var int SE_JinaInGame;
var int SE_JinaJustDied;
var int SE_JinaRevivePending;
var int SE_JinaReviveDelayTicks;
var int SE_JinaReviveSuppressCast;
var int SE_JinaCheckLoopN;
var int SE_JinaLastManualResummonCl;
var int SE_JinaCastWasAlive;
const int SE_JINA_MANUAL_BLOCK_AUTO_CL = 8;
// Совместимость со старыми сборками (если где-то остался старый скрипт таймера)
var int SE_JinaReviveTimerDone;
var int SE_JinaReviveCdLeft;
var int SE_JinaCdDbgState; // 0=IDLE 1=RUNNING 2=FINISHED (C++ таймер)

const int SE_JINA_REVIVE_CD_SEC = 20;
// Задержка респавна — C++ SE_JINA_REVIVE_DELAY_MS (1000). Не путать с тиками CheckLoop (~1/с)!
const int SE_JINA_REVIVE_DELAY_TICKS = 0;
const int SE_JINA_CD_IDLE = 0;
const int SE_JINA_CD_RUNNING = 1;
const int SE_JINA_CD_FINISHED = 2;
const int SE_SUMMON_BAR_DEFAULT = 1;
const int SE_REQ_CIRCLE_JINA = 2;
const int SE_REQ_CIRCLE_JINA_REVIVE = 2;
const int SE_REQ_CIRCLE_SLOT1 = 3;
const int SE_REQ_CIRCLE_SLOT2 = 4;
const int SE_REQ_CIRCLE_MANA = 1;
const int SE_COST_LP_MANA = 7;
const int SE_COST_GOLD_MANA = 1000;
const int SE_COST_LP_JINA = 10;
const int SE_COST_GOLD_JINA = 1000;
const int SE_COST_LP_SLOT1 = 15;
const int SE_COST_GOLD_SLOT1 = 2000;
const int SE_COST_LP_SLOT2 = 20;
const int SE_COST_GOLD_SLOT2 = 4000;
const int SE_COST_LP_WOLF_PACK = 12;
const int SE_COST_GOLD_WOLF_PACK = 1500;
const int SE_REQ_CIRCLE_WOLF_PACK = 2;
const int SE_BONUS_MANA = 25;

func void SE_JinaCancelAutoReviveQueue()
{
    SE_JinaRevivePending = FALSE;
    SE_JinaJustDied = FALSE;
    if (SE_DllLoaded)
    {
        SE_JinaRevive_ClearDelay();
    };
};

func int SE_JinaManualBlocksAuto()
{
    if (SE_JinaLastManualResummonCl <= 0)
    {
        return FALSE;
    };
    if (SE_JinaCheckLoopN <= SE_JinaLastManualResummonCl + SE_JINA_MANUAL_BLOCK_AUTO_CL)
    {
        return TRUE;
    };
    return FALSE;
};

func int SE_JinaIsPetReallyUp()
{
    if (!JinaWolfIsUp)
    {
        return FALSE;
    };
    if (!Hlp_IsValidNpc(pet_jina))
    {
        return FALSE;
    };
    if (Npc_IsDead(pet_jina))
    {
        return FALSE;
    };
    return TRUE;
};

func void SE_JinaClearStaleUpFlag()
{
    if (SE_JinaIsPetReallyUp())
    {
        if (!JinaWolfIsUp)
        {
            JinaWolfIsUp = TRUE;
        };
        return;
    };
    if (!JinaWolfIsUp)
    {
        return;
    };
    if (!Hlp_IsValidNpc(pet_jina) || Npc_IsDead(pet_jina))
    {
        JinaWolfIsUp = FALSE;
    };
};

func void SE_JinaOnSuccessfulSummon()
{
    if (!SE_JinaAutoReviveLearned)
    {
        return;
    };
    if (!JinaWolfIsUp)
    {
        return;
    };
    SE_JinaReviveEverSummoned = TRUE;
    SE_JinaWasAlive = TRUE;
    SE_JinaRevive_ArmCd();
    SE_JinaReviveReady = FALSE;
    SE_JinaJustDied = FALSE;
};

func int SE_HeroMagicCircle()
{
    return Npc_GetTalentSkill(hero, NPC_TALENT_MAGE);
};

func int SE_IsGallahadTeacherActive()
{
    if (TALIASANTEACHMAGIC)
    {
        return TRUE;
    };
    return FALSE;
};

func int SE_IsUndeadSummoner()
{
    if (RX_IsNecroSummoner())
    {
        return TRUE;
    };
    return FALSE;
};

func int SE_HeroHasWolfRuneUnlocked()
{
    if (Npc_HasItems(hero, ItRu_SumWolf) >= 1)
    {
        return TRUE;
    };
    if (player_talent_runes[25])
    {
        return TRUE;
    };
    if (Npc_GetActiveSpell(hero) == SPL_SUMMONWOLF)
    {
        return TRUE;
    };
    return FALSE;
};

func int SE_HeroHasJinaRuneUnlocked()
{
    if (Npc_HasItems(hero, ItRu_SumJina) >= 1)
    {
        return TRUE;
    };
    if (JinaWolfReadyPet)
    {
        return TRUE;
    };
    return FALSE;
};

func void SE_ApplySummonBonus()
{
    RX_SummonCountMax = RX_SummonCountMax + 1;
    RX_GodGiftSummonMax = RX_GodGiftSummonMax + 1;
    RX_SUMMONMAX = RX_SUMMONMAX + 1;
    SE_PersistSummonMax = RX_SummonCountMax;
};

// NB: макс. мана считается через RX_GodGiftMana (как дары статуи), не через прямой hero.attribute.
func void SE_ApplyManaBonus()
{
    RX_GodGiftMana = RX_GodGiftMana + SE_BONUS_MANA;
    SE_PersistGodGiftMana = RX_GodGiftMana;
    hero.attribute[ATR_MANA_MAX] = hero.attribute[ATR_MANA_MAX] + SE_BONUS_MANA;
    hero.attribute[ATR_MANA] = hero.attribute[ATR_MANA] + SE_BONUS_MANA;
};

func int SE_TryPaySkillCost(var int lpCost, var int goldCost)
{
    if (hero.lp < lpCost)
    {
        AI_Print("SE_HINT_NEED_LP");
        return FALSE;
    };
    if (Npc_HasItems(hero, ItMi_Gold) < goldCost)
    {
        AI_Print("SE_HINT_NEED_GOLD");
        return FALSE;
    };
    hero.lp = hero.lp - lpCost;
    Npc_RemoveInvItems(hero, ItMi_Gold, goldCost);
    return TRUE;
};

func int SE_CanOfferJinaPerk()
{
    if (!SE_HeroHasJinaRuneUnlocked())
    {
        return FALSE;
    };
    if (SE_JinaFreeSlotLearned)
    {
        return FALSE;
    };
    if (SE_HeroMagicCircle() < SE_REQ_CIRCLE_JINA)
    {
        return FALSE;
    };
    return TRUE;
};

func int SE_CanOfferJinaAutoRevive()
{
    if (!SE_HeroHasJinaRuneUnlocked())
    {
        return FALSE;
    };
    if (SE_JinaAutoReviveLearned)
    {
        return FALSE;
    };
    if (SE_HeroMagicCircle() < SE_REQ_CIRCLE_JINA_REVIVE)
    {
        return FALSE;
    };
    return TRUE;
};

func int SE_CanOfferSlot1()
{
    if (!SE_HeroHasJinaRuneUnlocked())
    {
        return FALSE;
    };
    if (SE_SummonSlot1Learned)
    {
        return FALSE;
    };
    if (SE_HeroMagicCircle() < SE_REQ_CIRCLE_SLOT1)
    {
        return FALSE;
    };
    return TRUE;
};

func int SE_CanOfferSlot2()
{
    if (!SE_HeroHasJinaRuneUnlocked())
    {
        return FALSE;
    };
    if (SE_SummonSlot2Learned)
    {
        return FALSE;
    };
    if (SE_HeroMagicCircle() < SE_REQ_CIRCLE_SLOT2)
    {
        return FALSE;
    };
    return TRUE;
};

func int SE_CanOfferSummonMana()
{
    if (!SE_HeroHasJinaRuneUnlocked())
    {
        return FALSE;
    };
    if (SE_SummonManaLearned)
    {
        return FALSE;
    };
    if (SE_HeroMagicCircle() < SE_REQ_CIRCLE_MANA)
    {
        return FALSE;
    };
    return TRUE;
};

func void SE_LearnSlot1()
{
    if (SE_SummonSlot1Learned)
    {
        return;
    };
    if (!SE_CanOfferSlot1())
    {
        return;
    };
    if (!SE_TryPaySkillCost(SE_COST_LP_SLOT1, SE_COST_GOLD_SLOT1))
    {
        return;
    };
    SE_SummonSlot1Learned = TRUE;
    SE_ApplySummonBonus();
    Snd_Play("LevelUP");
    AI_Print("SE_MSG_LEARN_SLOT1");
};

func void SE_LearnSlot2()
{
    if (SE_SummonSlot2Learned)
    {
        return;
    };
    if (!SE_CanOfferSlot2())
    {
        return;
    };
    if (!SE_TryPaySkillCost(SE_COST_LP_SLOT2, SE_COST_GOLD_SLOT2))
    {
        return;
    };
    SE_SummonSlot2Learned = TRUE;
    SE_ApplySummonBonus();
    Snd_Play("LevelUP");
    AI_Print("SE_MSG_LEARN_SLOT2");
};

func void SE_LearnJinaPerk()
{
    if (SE_JinaFreeSlotLearned)
    {
        return;
    };
    if (!SE_CanOfferJinaPerk())
    {
        return;
    };
    if (!SE_TryPaySkillCost(SE_COST_LP_JINA, SE_COST_GOLD_JINA))
    {
        return;
    };
    SE_JinaFreeSlotLearned = TRUE;
    Snd_Play("LevelUP");
    AI_Print("SE_MSG_LEARN_JINA");
};

func void SE_LearnJinaAutoRevive()
{
    if (SE_JinaAutoReviveLearned)
    {
        return;
    };
    if (!SE_CanOfferJinaAutoRevive())
    {
        return;
    };
    SE_JinaAutoReviveLearned = TRUE;
    SE_PersistJinaAutoRevive = TRUE;
    SE_JinaReviveEverSummoned = FALSE;
    SE_JinaReviveReady = TRUE;
    SE_JinaWasAlive = FALSE;
    SE_JinaInGame = FALSE;
    SE_JinaRevivePending = FALSE;
    SE_JinaReviveDelayTicks = 0;
    SE_JinaJustDied = FALSE;
    SE_JinaCheckLoopN = 0;
    SE_JinaLastManualResummonCl = 0;
    SE_JinaReviveCdLeft = 0;
    if (JinaWolfIsUp)
    {
        SE_JinaReviveEverSummoned = TRUE;
        SE_JinaWasAlive = TRUE;
    };
    Snd_Play("LevelUP");
    AI_Print("SE_MSG_LEARN_JINA_REVIVE");
};

func int SE_CanOfferWolfPackSummon()
{
    if (!SE_HeroHasWolfRuneUnlocked())
    {
        return FALSE;
    };
    if (SE_WolfPackSummonLearned)
    {
        return FALSE;
    };
    if (SE_HeroMagicCircle() < SE_REQ_CIRCLE_WOLF_PACK)
    {
        return FALSE;
    };
    return TRUE;
};

func void SE_LearnWolfPackSummon()
{
    if (SE_WolfPackSummonLearned)
    {
        return;
    };
    if (!SE_CanOfferWolfPackSummon())
    {
        return;
    };
    if (!SE_TryPaySkillCost(SE_COST_LP_WOLF_PACK, SE_COST_GOLD_WOLF_PACK))
    {
        return;
    };
    SE_WolfPackSummonLearned = TRUE;
    SE_PersistWolfPackSummon = TRUE;
    SE_WolfPackBurstRunning = FALSE;
    Snd_Play("LevelUP");
    AI_Print("SE_MSG_LEARN_WOLF_PACK");
};

func void SE_RestoreWolfPackFromPersist()
{
    if (SE_PersistWolfPackSummon)
    {
        SE_WolfPackSummonLearned = TRUE;
    };
};

func void SE_RestoreJinaAutoReviveFromPersist()
{
    if (SE_PersistJinaAutoRevive)
    {
        SE_JinaAutoReviveLearned = TRUE;
    };
};

func void SE_LearnSummonMana()
{
    if (SE_SummonManaLearned)
    {
        return;
    };
    if (!SE_CanOfferSummonMana())
    {
        return;
    };
    if (!SE_TryPaySkillCost(SE_COST_LP_MANA, SE_COST_GOLD_MANA))
    {
        return;
    };
    SE_SummonManaLearned = TRUE;
    SE_ApplyManaBonus();
    Snd_Play("LevelUP");
    AI_Print("SE_MSG_LEARN_MANA");
};

func int SE_Debug_ItemInstId(var c_item itm)
{
    if (!Hlp_IsValidItem(itm))
    {
        return 0;
    };
    return Hlp_GetInstanceId(itm);
};

func void SE_Debug_PrintHoldChange(var string label, var int instId)
{
    var string msg;
    msg = ConcatStrings(label, IntToString(instId));
    AI_Print(msg);
};

func void SE_DebugPollHeldItems()
{
    var c_item mw;
    var c_item rw;
    var int spellId;
    var int mwId;
    var int rwId;

    if (!hero)
    {
        return;
    };
    mw = Npc_GetEquippedMeleeWeapon(hero);
    rw = Npc_GetEquippedRangedWeapon(hero);
    mwId = SE_Debug_ItemInstId(mw);
    rwId = SE_Debug_ItemInstId(rw);
    spellId = Npc_GetActiveSpell(hero);
    if (mwId != SE_DebugLastMeleeId)
    {
        SE_DebugLastMeleeId = mwId;
        SE_Debug_PrintHoldChange("SE hand melee id=", mwId);
        if (mwId > 0 && Hlp_GetInstanceId(ItRu_SumWolf) == mwId)
        {
            AI_Print("SE hand melee=ItRu_SumWolf");
        };
    };
    if (rwId != SE_DebugLastRangedId)
    {
        SE_DebugLastRangedId = rwId;
        SE_Debug_PrintHoldChange("SE hand range id=", rwId);
        if (rwId > 0 && Hlp_GetInstanceId(ItRu_SumWolf) == rwId)
        {
            AI_Print("SE hand range=ItRu_SumWolf");
        };
    };
    if (spellId != SE_DebugLastSpellId)
    {
        SE_DebugLastSpellId = spellId;
        SE_Debug_PrintHoldChange("SE active spell id=", spellId);
        if (spellId == SPL_SUMMONWOLF)
        {
            AI_Print("SE spell=SPL_SUMMONWOLF");
        };
    };
};

// SummonersExtention.dll — summon HP bars (EB draw)
// НЕ объявлять SE_JinaRevive_ArmCd/SyncCd/DisarmCd и SE_WolfPack_*BurstDelay* здесь —
// пустые {} перекрывают C++ external (таймеры не работают).
func void SE_NativeSyncBarIni() {};
func void SE_NativeRunBarHudTick() {};
