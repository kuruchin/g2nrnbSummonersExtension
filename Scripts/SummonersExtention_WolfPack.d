// SummonersExtention — перк «Стая волков» (руна призыва волка, ItRu_SumWolf)

META
{
    Parser = Game;
    Engine = G2A;
    After = SummonersExtention_JinaRevive.d;
};

func void SE_WolfPack_StopBurst()
{
    SE_WolfPackBurstRunning = FALSE;
    if (SE_DllLoaded)
    {
        SE_WolfPack_ClearBurstDelay();
    };
};

func int SE_WolfPack_JinaAliveForPack()
{
    return SE_JinaIsPetReallyUp();
};

func int SE_WolfPack_GetManaCost()
{
    // NB: стоимость варга зависит от улучшения руны (rx_sumgolemlvl), не от spl_cost_summonwolf.
    return getsummongolemcost();
};

func int SE_WolfPack_CanSpawnAnother()
{
    var int cost;
    var int maxSum;
    if (!SE_WolfPackSummonLearned)
    {
        return FALSE;
    };
    if (!SE_WolfPack_JinaAliveForPack())
    {
        return FALSE;
    };
    cost = SE_WolfPack_GetManaCost();
    maxSum = GetSummonCountMax();
    if (RX_SummonCount >= maxSum)
    {
        return FALSE;
    };
    if (hero.attribute[ATR_MANA] <= cost)
    {
        return FALSE;
    };
    return TRUE;
};

func int SE_WolfPack_SpawnOneWarg()
{
    var int cost;
    var int lvl;
    if (!SE_WolfPack_CanSpawnAnother())
    {
        return FALSE;
    };
    cost = SE_WolfPack_GetManaCost();
    lvl = rx_sumgolemlvl;
    if (lvl <= 0)
    {
        Wld_SpawnNpcRange(hero, summoned_warg, 1, 500.0);
    }
    else if (lvl == 1)
    {
        Wld_SpawnNpcRange(hero, summoned_warg1, 1, 500.0);
    }
    else if (lvl == 2)
    {
        Wld_SpawnNpcRange(hero, summoned_warg2, 1, 500.0);
    }
    else
    {
        Wld_SpawnNpcRange(hero, summoned_warg3, 1, 500.0);
    };
    hero.attribute[ATR_MANA] = hero.attribute[ATR_MANA] - cost;
    RX_SummonCount = RX_SummonCount + 1;
    RX_UpdateRuneInfo(hero);
    RX_PlayEffect("spellFX_SummonCreature_ORIGIN", hero);
    return TRUE;
};

func void SE_WolfPack_StartBurst()
{
    if (!SE_WolfPackSummonLearned)
    {
        return;
    };
    if (!SE_WolfPack_JinaAliveForPack())
    {
        return;
    };
    SE_WolfPackBurstRunning = TRUE;
    if (SE_DllLoaded)
    {
        SE_WolfPack_ArmBurstDelay();
    };
};

func void SE_WolfPack_BurstTick()
{
    if (!SE_WolfPackSummonLearned)
    {
        return;
    };
    if (!SE_WolfPackBurstRunning)
    {
        return;
    };
    if (!SE_WolfPack_JinaAliveForPack())
    {
        SE_WolfPack_StopBurst();
        return;
    };
    if (!SE_DllLoaded)
    {
        SE_WolfPack_StopBurst();
        return;
    };
    SE_WolfPack_SyncBurstDelay();
    if (SE_WolfPackBurstDelayTicks)
    {
        return;
    };
    if (!SE_WolfPack_CanSpawnAnother())
    {
        SE_WolfPack_StopBurst();
        return;
    };
    if (!SE_WolfPack_SpawnOneWarg())
    {
        SE_WolfPack_StopBurst();
        return;
    };
    if (SE_DllLoaded)
    {
        SE_WolfPack_ArmBurstDelay();
    };
};

func int SE_WolfPack_IsSumWolfItemTitle(var string title)
{
    if (Hlp_StrCmp(title, "SE_SUMWOLF_ITEM_NAME"))
    {
        return TRUE;
    };
    if (Hlp_StrCmp(title, "SE_SUMWOLF_SPELL_NAME"))
    {
        return TRUE;
    };
    return FALSE;
};

func void AI_PrintItemInfo(var string title, var string info, var int p2, var int p3)
{
    var string outInfo;
    outInfo = info;
    if (SE_WolfPackSummonLearned && SE_WolfPack_IsSumWolfItemTitle(title))
    {
        outInfo = ConcatStrings(info, "SE_WOLF_PACK_UPGRADE_SUFFIX");
    };
    AI_PrintItemInfo_Old(title, outInfo, p2, p3);
};

func int spell_logic_summonwolf(var int manainvested)
{
    if (SE_WolfPackSummonLearned && SE_WolfPackBurstRunning)
    {
        return spl_sendstop;
    };
    return spell_logic_summonwolf_Old(manainvested);
};

func void spell_cast_summonwolf()
{
    spell_cast_summonwolf_Old();
    if (SE_WolfPackSummonLearned && SE_WolfPack_JinaAliveForPack())
    {
        SE_WolfPack_StartBurst();
    };
};

func void RX_CheckLoop()
{
    if (hero && SE_WolfPackSummonLearned)
    {
        SE_WolfPack_BurstTick();
    };
    RX_CheckLoop_Old();
};
