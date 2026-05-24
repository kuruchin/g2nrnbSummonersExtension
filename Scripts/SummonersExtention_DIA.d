// SummonersExtention - Taliasan dialogs
// Edit here in UTF-8. Deploy: Scripts\fix_and_deploy.ps1

META
{
    Parser = Game;
    Engine = G2A;
    After = SummonersExtention_Hook.d;
};

INSTANCE DIA_SE_NeedJinaRune_01_00 (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 951;
    description = "SE_DLG_NEED_JINA_RUNE";
};

INSTANCE DIA_SE_GallahadSummon (C_INFO)
{
    npc = VLK_6027_TALIASAN;
    nr = 950;
    condition = DIA_SE_GallahadSummon_Condition;
    information = DIA_SE_GallahadSummon_Info;
    important = FALSE;
    permanent = TRUE;
    description = "SE_DESC_MENU";
};

func int DIA_SE_GallahadSummon_Condition()
{
    if (!SE_IsGallahadTeacherActive())
    {
        return FALSE;
    };
    return TRUE;
};

func void SE_GallahadSummonStayInMainMenu()
{
    Info_ClearChoices(DIA_SE_GallahadSummon);
};

func void SE_ShowSummonRequirementHint()
{
    if (SE_CanOfferJinaPerk() || SE_CanOfferSlot1() || SE_CanOfferSlot2() || SE_CanOfferSummonMana())
    {
        return;
    };

    if (SE_JinaFreeSlotLearned && SE_SummonSlot1Learned && SE_SummonSlot2Learned && SE_SummonManaLearned)
    {
        AI_Print("SE_HINT_ALL_LEARNED");
        SE_GallahadSummonStayInMainMenu();
        return;
    };

    if (!SE_SummonManaLearned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_MANA)
    {
        AI_Print("SE_HINT_NEED_CIRCLE_1");
        SE_GallahadSummonStayInMainMenu();
        return;
    };

    if (!SE_JinaFreeSlotLearned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_JINA)
    {
        AI_Print("SE_HINT_NEED_CIRCLE_2");
        SE_GallahadSummonStayInMainMenu();
        return;
    };

    if (!SE_SummonSlot1Learned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_SLOT1)
    {
        AI_Print("SE_HINT_NEED_CIRCLE_3");
        SE_GallahadSummonStayInMainMenu();
        return;
    };

    if (!SE_SummonSlot2Learned && SE_HeroMagicCircle() < SE_REQ_CIRCLE_SLOT2)
    {
        AI_Print("SE_HINT_NEED_CIRCLE_4");
        SE_GallahadSummonStayInMainMenu();
    };
};

func void SE_OpenGallahadSummonMenu()
{
    Info_ClearChoices(DIA_SE_GallahadSummon);

    if (SE_CanOfferSummonMana())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_MANA", DIA_SE_LearnMana_Info);
    };

    if (SE_CanOfferJinaPerk())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_JINA", DIA_SE_LearnJina_Info);
    };

    if (SE_CanOfferSlot1())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_SLOT1", DIA_SE_LearnSlot1_Info);
    };

    if (SE_CanOfferSlot2())
    {
        Info_AddChoice(DIA_SE_GallahadSummon, "SE_CHOICE_SLOT2", DIA_SE_LearnSlot2_Info);
    };

    Info_AddChoice(DIA_SE_GallahadSummon, DIALOG_BACK, DIA_SE_SummonExtension_Back);
};

func void DIA_SE_GallahadSummon_Info()
{
    if (!SE_HeroHasJinaRuneUnlocked())
    {
        AI_Output(self, other, "DIA_SE_NeedJinaRune_01_00");
        SE_GallahadSummonStayInMainMenu();
        return;
    };

    if (!SE_CanOfferJinaPerk() && !SE_CanOfferSlot1() && !SE_CanOfferSlot2() && !SE_CanOfferSummonMana())
    {
        SE_ShowSummonRequirementHint();
        return;
    };

    SE_OpenGallahadSummonMenu();
};

func void DIA_SE_SummonExtension_Back()
{
    SE_GallahadSummonStayInMainMenu();
};

func void DIA_SE_LearnSlot1_Info()
{
    SE_LearnSlot1();
    SE_OpenGallahadSummonMenu();
};

func void DIA_SE_LearnSlot2_Info()
{
    SE_LearnSlot2();
    SE_OpenGallahadSummonMenu();
};

func void DIA_SE_LearnJina_Info()
{
    SE_LearnJinaPerk();
    SE_OpenGallahadSummonMenu();
};

func void DIA_SE_LearnMana_Info()
{
    SE_LearnSummonMana();
    SE_OpenGallahadSummonMenu();
};
