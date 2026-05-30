// SummonersExtention — HP-bary prizyvov (EB: oCViewStatusBar na screen)

META
{
    Parser = Game;
    Engine = G2A;
    After = SummonersExtention_WolfPack.d;
};

func void B_UPDATESTAMINABAR()
{
    B_UPDATESTAMINABAR_Old();
    if (!hero)
    {
        return;
    };
    SE_NativeRunBarHudTick();
};
