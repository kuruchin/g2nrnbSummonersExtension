# -*- coding: utf-8 -*-
import pathlib
import re
import subprocess

SCRIPTS = pathlib.Path(__file__).resolve().parent
MAIN = SCRIPTS / "SummonersExtention.d"

REPLACEMENTS = [
    (
        r'(?<=SE_LearnSlot1\(\)[\s\S]*?Snd_Play\("LevelUP"\);\s*)AI_Print\("[^"]*"\);',
        'AI_Print("\u0412\u044b\u0443\u0447\u0435\u043d\u043e \u0440\u0430\u0441\u0448\u0438\u0440\u0435\u043d\u0438\u0435 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 I. \u041b\u0438\u043c\u0438\u0442 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0443\u0432\u0435\u043b\u0438\u0447\u0435\u043d.");',
    ),
    (
        r'(?<=SE_LearnSlot2\(\)[\s\S]*?Snd_Play\("LevelUP"\);\s*)AI_Print\("[^"]*"\);',
        'AI_Print("\u0412\u044b\u0443\u0447\u0435\u043d\u043e \u0440\u0430\u0441\u0448\u0438\u0440\u0435\u043d\u0438\u0435 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 II. \u041b\u0438\u043c\u0438\u0442 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0443\u0432\u0435\u043b\u0438\u0447\u0435\u043d.");',
    ),
    (
        r'(?<=SE_LearnJinaPerk\(\)[\s\S]*?Snd_Play\("LevelUP"\);\s*)AI_Print\("[^"]*"\);',
        'AI_Print("\u0414\u0436\u0438\u043d\u0430 \u0431\u043e\u043b\u044c\u0448\u0435 \u043d\u0435 \u0437\u0430\u043d\u0438\u043c\u0430\u0435\u0442 \u0441\u043b\u043e\u0442 \u043f\u0440\u0438\u0437\u044b\u0432\u0430.");',
    ),
]

text = MAIN.read_text(encoding="utf-8", errors="replace")
for pattern, repl in REPLACEMENTS:
    text = re.sub(pattern, repl, text, count=1)
MAIN.write_text(text, encoding="utf-8")
print("fixed:", "\u0412\u044b\u0443\u0447\u0435\u043d\u043e" in text)

subprocess.run(
    ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(SCRIPTS / "deploy.ps1")],
    check=True,
)

aut = (pathlib.Path(r"d:\Games\Steam\steamapps\common\Gothic II\system\Autorun") / "SummonersExtention.d").read_bytes()
print("deploy ok:", "\u0412\u044b\u0443\u0447\u0435\u043d\u043e".encode("cp1251") in aut)
