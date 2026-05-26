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
var int SE_NecroGallahadRefused;

// Extra summon HP bars (C++ SE_DrawAllBars_Eb in B_UPDATESTAMINABAR)
var int SE_SummonBarShow;
var int SE_SummonBarPosY;
var int SE_DllLoaded;

// Порог опыта на начале текущего уровня уника (для % заполнения, сохраняется в сейве)
var int SE_JinaWolfExpFloor;
var int SE_JinaWolfExpTrackLvl;
var int SE_CraitExpFloor;
var int SE_CraitExpTrackLvl;
var int SE_SkeletonUniqExpFloor;
var int SE_SkeletonUniqExpTrackLvl;
var int SE_DemonHubExpFloor;
var int SE_DemonHubExpTrackLvl;

const int SE_SUMMON_BAR_DEFAULT = 1;
const int SE_REQ_CIRCLE_JINA = 2;
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
const int SE_BONUS_MANA = 25;

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

// SummonersExtention.dll — summon HP bars (EB draw)
func void SE_NativeSyncBarIni() {};
func void SE_NativeRunBarHudTick() {};
