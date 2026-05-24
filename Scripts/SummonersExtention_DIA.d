// SummonersExtention - Taliasan (Gallahad) dialogs
// Speech: text in // comment after AI_Output (Karma / CompileOU). No AI_Print for NPC lines.
// Edit here in UTF-8. Deploy: Scripts\fix_and_deploy.ps1

META
{
    Parser = Game;
    Engine = G2A;
    After = SummonersExtention.d;
};

INSTANCE DIA_SE_GallahadSummon (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 60;
    condition = DIA_SE_GallahadSummon_Condition;
    information = DIA_SE_GallahadSummon_Info;
    important = FALSE;
    permanent = TRUE;
    description = "SE_DESC_MENU";
};

INSTANCE DIA_SE_LearnMana (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 960;
    important = FALSE;
    permanent = FALSE;
    description = "SE_CHOICE_MANA";
    information = DIA_SE_LearnMana_Info;
};

INSTANCE DIA_SE_LearnJina (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 961;
    important = FALSE;
    permanent = FALSE;
    description = "SE_CHOICE_JINA";
    information = DIA_SE_LearnJina_Info;
};

INSTANCE DIA_SE_LearnSlot1 (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 962;
    important = FALSE;
    permanent = FALSE;
    description = "SE_CHOICE_SLOT1";
    information = DIA_SE_LearnSlot1_Info;
};

INSTANCE DIA_SE_LearnSlot2 (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 963;
    important = FALSE;
    permanent = FALSE;
    description = "SE_CHOICE_SLOT2";
    information = DIA_SE_LearnSlot2_Info;
};

func int DIA_SE_GallahadSummon_Condition()
{
    if (!SE_IsGallahadTeacherActive())
    {
        return FALSE;
    };
    if (SE_IsUndeadSummoner() && SE_NecroGallahadRefused)
    {
        return FALSE;
    };
    return TRUE;
};

func void SE_ShowSummonRequirementHint()
{
    if (SE_CanOfferJinaPerk() || SE_CanOfferSlot1() || SE_CanOfferSlot2() || SE_CanOfferSummonMana())
    {
        return;
    };

    if (SE_JinaFreeSlotLearned && SE_SummonSlot1Learned && SE_SummonSlot2Learned && SE_SummonManaLearned)
    {
        AI_Output(self, other, "DIA_SE_Hint_AllLearned_01_00"); // SE_DLG_HINT_ALL
        return;
    };

    if (!SE_SummonManaLearned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_MANA)
    {
        AI_Output(self, other, "DIA_SE_Hint_Circle1_01_00"); // SE_DLG_HINT_C1
        return;
    };

    if (!SE_JinaFreeSlotLearned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_JINA)
    {
        AI_Output(self, other, "DIA_SE_Hint_Circle2_01_00"); // SE_DLG_HINT_C2
        return;
    };

    if (!SE_SummonSlot1Learned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_SLOT1)
    {
        AI_Output(self, other, "DIA_SE_Hint_Circle3_01_00"); // SE_DLG_HINT_C3
        return;
    };

    if (!SE_SummonSlot2Learned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_SLOT2)
    {
        AI_Output(self, other, "DIA_SE_Hint_Circle4_01_00"); // SE_DLG_HINT_C4
    };
};

func void SE_OpenGallahadSummonMenu()
{
    var int hasChoice;

    hasChoice = FALSE;
    Info_ClearChoices(DIA_SE_GallahadSummon);

    if (SE_CanOfferSummonMana())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_MANA", DIA_SE_LearnMana);
        hasChoice = TRUE;
    };

    if (SE_CanOfferJinaPerk())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_JINA", DIA_SE_LearnJina);
        hasChoice = TRUE;
    };

    if (SE_CanOfferSlot1())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_SLOT1", DIA_SE_LearnSlot1);
        hasChoice = TRUE;
    };

    if (SE_CanOfferSlot2())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_SLOT2", DIA_SE_LearnSlot2);
        hasChoice = TRUE;
    };

    if (hasChoice)
    {
        Info_AddChoice(DIA_SE_GallahadSummon, DIALOG_BACK, RX_ClearDialog);
    };
};

func void DIA_SE_GallahadSummon_Info()
{
    if (SE_IsUndeadSummoner())
    {
        AI_Output(self, other, "DIA_SE_NecroRefuse_01_00"); // SE_DLG_NECRO_REFUSE
        SE_NecroGallahadRefused = TRUE;
        return;
    };

    if (!SE_HeroHasJinaRuneUnlocked())
    {
        AI_Output(self, other, "DIA_SE_NeedJinaRune_01_00"); // SE_DLG_NEED_JINA_RUNE
        return;
    };

    if (!SE_CanOfferJinaPerk() && !SE_CanOfferSlot1() && !SE_CanOfferSlot2() && !SE_CanOfferSummonMana())
    {
        SE_ShowSummonRequirementHint();
        return;
    };

    SE_OpenGallahadSummonMenu();
};

func void DIA_SE_LearnSlot1_Info()
{
    SE_LearnSlot1();
    if (SE_CanOfferJinaPerk() || SE_CanOfferSlot1() || SE_CanOfferSlot2() || SE_CanOfferSummonMana())
    {
        SE_OpenGallahadSummonMenu();
    };
};

func void DIA_SE_LearnSlot2_Info()
{
    SE_LearnSlot2();
    if (SE_CanOfferJinaPerk() || SE_CanOfferSlot1() || SE_CanOfferSlot2() || SE_CanOfferSummonMana())
    {
        SE_OpenGallahadSummonMenu();
    };
};

func void DIA_SE_LearnJina_Info()
{
    SE_LearnJinaPerk();
    if (SE_CanOfferJinaPerk() || SE_CanOfferSlot1() || SE_CanOfferSlot2() || SE_CanOfferSummonMana())
    {
        SE_OpenGallahadSummonMenu();
    };
};

func void DIA_SE_LearnMana_Info()
{
    SE_LearnSummonMana();
    if (SE_CanOfferJinaPerk() || SE_CanOfferSlot1() || SE_CanOfferSlot2() || SE_CanOfferSummonMana())
    {
        SE_OpenGallahadSummonMenu();
    };
};
