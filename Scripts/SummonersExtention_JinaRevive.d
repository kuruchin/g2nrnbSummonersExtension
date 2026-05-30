// SummonersExtention - Jina auto-revive (death + delay, no TimerTick summon)

META
{
    Parser = Game;
    Engine = G2A;
    After = SummonersExtention_Hook.d;
};

func void SE_JinaAutoRevive_FallbackSpawn()
{
    if (JinaWolfIsUp)
    {
        return;
    };
    if (SE_JinaInGame)
    {
        return;
    };
    SE_JinaInGame = TRUE;
    RX_SummonCount = RX_SummonCount + 1;
    Wld_SpawnNpcRange(hero, pet_jina, 1, 500.0);
    JinaWolfIsUp = TRUE;
    RX_UpdateRuneInfo(hero);
    hero.attribute[ATR_MANA] = hero.attribute[ATR_MANA] - spl_cost_jina;
    RX_PlayEffect("spellFX_SUMJINA", hero);
};

func void SE_JinaAutoRevive_DoSummon()
{
    var int result;
    if (JinaWolfIsUp)
    {
        return;
    };
    if (SE_JinaInGame)
    {
        return;
    };
    SE_JinaSummonBypass = TRUE;
    SE_JinaAutoRevive_FallbackSpawn();
    SE_JinaSummonBypass = FALSE;
    result = 0;
    if (JinaWolfIsUp)
    {
        result = 2;
    };
    if (JinaWolfIsUp)
    {
        SE_JinaInGame = TRUE;
        SE_JinaOnSuccessfulSummon();
    }
    else
    {
        SE_JinaInGame = FALSE;
    };
};

func void SE_JinaTryAutoRevive()
{
    if (SE_JinaManualBlocksAuto())
    {
        return;
    };
    if (!SE_JinaAutoReviveLearned)
    {
        return;
    };
    if (!SE_JinaReviveEverSummoned)
    {
        return;
    };
    if (!SE_JinaReviveReady)
    {
        return;
    };
    if (SE_JinaIsPetReallyUp())
    {
        return;
    };
    if (JinaWolfIsUp)
    {
        return;
    };
    if (SE_JinaInGame)
    {
        return;
    };
    if (hero.attribute[ATR_MANA] <= spl_cost_jina)
    {
        return;
    };
    if (Npc_HasItems(hero, ItRu_SumJina) <= 0)
    {
        return;
    };
    SE_JinaAutoRevive_DoSummon();
};

func void SE_JinaRevive_TimerTick()
{
    SE_JinaRevive_SyncCd();
    if (!SE_JinaReviveReady)
    {
        if (SE_JinaCdDbgState == SE_JINA_CD_FINISHED)
        {
            SE_JinaReviveReady = TRUE;
        };
    };
};

func void SE_JinaRevive_PollDelay()
{
    if (!SE_DllLoaded)
    {
        return;
    };
    SE_JinaRevive_SyncDelay();
};

func void SE_JinaRevive_ProcessPending()
{
    var int petUp;
    if (!SE_JinaRevivePending)
    {
        return;
    };
    if (SE_JinaManualBlocksAuto())
    {
        SE_JinaRevivePending = FALSE;
        SE_JinaJustDied = FALSE;
        if (SE_DllLoaded)
        {
            SE_JinaRevive_ClearDelay();
        };
        return;
    };
    if (SE_JinaReviveDelayTicks > 0)
    {
        return;
    };
    if (SE_JinaCdDbgState == SE_JINA_CD_RUNNING)
    {
        return;
    };
    if (!SE_JinaReviveReady)
    {
        SE_JinaReviveReady = TRUE;
    };
    petUp = SE_JinaIsPetReallyUp();
    if (petUp)
    {
        SE_JinaRevivePending = FALSE;
        SE_JinaJustDied = FALSE;
        if (SE_DllLoaded)
        {
            SE_JinaRevive_ClearDelay();
        };
        return;
    };
    if (SE_JinaInGame && !JinaWolfIsUp)
    {
        SE_JinaInGame = FALSE;
    };
    if (JinaWolfIsUp)
    {
        SE_JinaRevivePending = FALSE;
        SE_JinaJustDied = FALSE;
        if (SE_DllLoaded)
        {
            SE_JinaRevive_ClearDelay();
        };
        return;
    };
    SE_JinaRevivePending = FALSE;
    SE_JinaTryAutoRevive();
    if (SE_DllLoaded)
    {
        SE_JinaRevive_ClearDelay();
    };
};

func void SE_JinaDied()
{
    if (!SE_JinaAutoReviveLearned)
    {
        return;
    };
    if (!SE_JinaReviveEverSummoned)
    {
        return;
    };
    if (SE_JinaCdDbgState == SE_JINA_CD_RUNNING)
    {
        return;
    };
    if (SE_JinaManualBlocksAuto())
    {
        return;
    };
    if (SE_JinaIsPetReallyUp() || JinaWolfIsUp)
    {
        return;
    };
    SE_JinaJustDied = TRUE;
    SE_JinaRevivePending = TRUE;
    SE_JinaInGame = FALSE;
    if (SE_DllLoaded)
    {
        SE_JinaRevive_ArmDelay();
    };
};

func void SE_JinaLiveEvent()
{
    var int petUp;
    SE_JinaClearStaleUpFlag();
    petUp = SE_JinaIsPetReallyUp();
    if (SE_JinaRevivePending)
    {
        if (petUp)
        {
            SE_JinaWasAlive = TRUE;
            SE_JinaReviveEverSummoned = TRUE;
            SE_JinaRevivePending = FALSE;
            SE_JinaJustDied = FALSE;
            if (SE_DllLoaded)
            {
                SE_JinaRevive_ClearDelay();
            };
            return;
        };
        if (JinaWolfIsUp)
        {
            JinaWolfIsUp = FALSE;
        };
        return;
    };
    if (petUp)
    {
        SE_JinaWasAlive = TRUE;
        SE_JinaReviveEverSummoned = TRUE;
        SE_JinaJustDied = FALSE;
        return;
    };
    if (SE_JinaWasAlive)
    {
        SE_JinaWasAlive = FALSE;
        SE_JinaDied();
        return;
    };
};

func void SE_JinaSyncInGameFlag()
{
    if (SE_JinaInGame)
    {
        if (!JinaWolfIsUp)
        {
            if (SE_JinaIsPetReallyUp())
            {
                JinaWolfIsUp = TRUE;
            }
            else if (SE_JinaCdDbgState != SE_JINA_CD_FINISHED)
            {
                SE_JinaInGame = FALSE;
            };
        };
    };
};

func void RX_CheckLoop()
{
    if (hero && SE_JinaAutoReviveLearned)
    {
        SE_JinaCheckLoopN = SE_JinaCheckLoopN + 1;
        if (SE_DllLoaded)
        {
            SE_JinaRevive_TimerTick();
        };
        SE_JinaSyncInGameFlag();
        SE_JinaLiveEvent();
        SE_JinaRevive_PollDelay();
        SE_JinaRevive_ProcessPending();
    };
    RX_CheckLoop_Old();
};
