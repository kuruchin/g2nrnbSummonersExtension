// SummonersExtention - hooks for NB summon limit checks (Jina free slot)

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
    SE_JinaCastWasAlive = SE_JinaWasAlive;
    if (JinaWolfIsUp)
    {
        return FALSE;
    };
    if (SE_JinaIsPetReallyUp())
    {
        return FALSE;
    };
    if (SE_JinaInGame)
    {
        return FALSE;
    };
    if (SE_JinaRevivePending)
    {
        return FALSE;
    };
    if (SE_JinaReviveDelayTicks > 0)
    {
        return FALSE;
    };
    if (SE_JinaFreeSlotLearned || SE_JinaAutoReviveLearned)
    {
        SE_JinaSummonBypass = TRUE;
    };
    result = spell_logic_sumjina_Old(manainvested);
    SE_JinaSummonBypass = FALSE;
    if (!JinaWolfIsUp && SE_JinaIsPetReallyUp())
    {
        JinaWolfIsUp = TRUE;
    };
    if (SE_JinaAutoReviveLearned && result && JinaWolfIsUp)
    {
        SE_JinaInGame = TRUE;
        SE_JinaOnSuccessfulSummon();
        SE_JinaCancelAutoReviveQueue();
        if (SE_JinaCastWasAlive)
        {
            SE_JinaLastManualResummonCl = SE_JinaCheckLoopN;
        };
    };
    return result;
};
