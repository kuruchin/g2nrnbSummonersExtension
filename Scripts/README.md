# Скрипты мода (Daedalus)

Сюда кладите исходники `.d` после распаковки `AB_Scripts.vdf`.

Черновик логики навыка (псевдокод — **не компилировать как есть**, пока не найдёте реальные имена функций в AB):

```daedalus
// При изучении навыка «Расширенный призыв I»
func void SE_OnLearn_SummonSlot1()
{
    RX_SummonCountMax = RX_SummonCountMax + 1;
};

// При изучении навыка «Расширенный призыв II»
func void SE_OnLearn_SummonSlot2()
{
    RX_SummonCountMax = RX_SummonCountMax + 1;
};
```

Подключение: скомпилировать через GothicSourcer → `system\Autorun\` или отдельный `.vdf` в `Data\`.
