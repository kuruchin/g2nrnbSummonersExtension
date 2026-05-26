// SummonersExtention — HP-bary prizyvov (EB: oCViewStatusBar na screen)

META
{
    Parser = Game;
    Engine = G2A;
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
