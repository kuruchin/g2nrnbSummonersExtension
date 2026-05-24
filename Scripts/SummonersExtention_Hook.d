// SummonersExtention - hooks for NB summon limit checks (Jina free slot)
// Edit here in UTF-8. Deploy to game: Scripts\deploy.ps1 (converts to CP1251)

META
{
    Parser = Game;
    Engine = G2A;
    After = SummonersExtention.d;
};

func int SE_JinaEffectiveSlotBonus()
{
    if (!SE_JinaFreeSlotLearned)
    {
        return 0;
    };
    if (JinaWolfIsUp)
    {
        return 1;
    };
    if (SE_JinaSummonBypass)
    {
        return 1;
    };
    return 0;
};

func int GetSummonCountMax()
{
    var int maxVal;
    var int bonus;

    maxVal = GetSummonCountMax_Old();
    bonus = SE_JinaEffectiveSlotBonus();
    if (bonus > 0)
    {
        maxVal = maxVal + bonus;
    };
    return maxVal;
};

func int spell_logic_sumjina(var int manainvested)
{
    var int result;

    if (SE_JinaFreeSlotLearned && !JinaWolfIsUp)
    {
        SE_JinaSummonBypass = TRUE;
    };

    result = spell_logic_sumjina_Old(manainvested);

    SE_JinaSummonBypass = FALSE;
    return result;
};
