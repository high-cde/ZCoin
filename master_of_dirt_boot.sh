#!/bin/bash
set -e

cd ~/HighCoin

echo "[ZDOS BOOT] Start"

mkdir -p docs

############################################
# 1. BOOT CSS
############################################

cat > docs/boot.css << 'EOF'
#boot-screen {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: #000000;
    color: #00ff00;
    font-family: Consolas, monospace;
    padding: 20px;
    z-index: 9999;
    overflow: hidden;
}

.boot-line {
    opacity: 0;
    animation: bootline 0.5s forwards;
}

@keyframes bootline {
    to { opacity: 1; }
}

#boot-screen.hide {
    animation: fadeout 1s forwards;
}

@keyframes fadeout {
    to { opacity: 0; visibility: hidden; }
}
EOF

echo "[ZDOS BOOT] CSS OK"

############################################
# 2. BOOT JS
############################################

cat > docs/boot.js << 'EOF'
document.addEventListener("DOMContentLoaded", function() {

    const lines = [
        "ZDOS Quantum Kernel v3.7",
        "Initializing DSN Gateway...",
        "Loading Z-Lang Runtime...",
        "Activating BlockZLang PoW Engine...",
        "Mounting HighVM...",
        "Checking node integrity...",
        "System online."
    ];

    const container = document.getElementById("boot-screen");

    let i = 0;
    function nextLine() {
        if (i < lines.length) {
            const div = document.createElement("div");
            div.className = "boot-line";
            div.style.animationDelay = (i * 0.3) + "s";
            div.textContent = lines[i];
            container.appendChild(div);
            i++;
            setTimeout(nextLine, 300);
        } else {
            setTimeout(() => {
                container.classList.add("hide");
            }, 1500);
        }
    }

    nextLine();
});
EOF

echo "[ZDOS BOOT] JS OK"

############################################
# 3. INIETTA BOOT SEQUENCE IN TUTTE LE PAGINE
############################################

for f in docs/*.html docs/*.md; do
    if ! grep -q "boot-screen" "$f"; then
        sed -i '1i <link rel="stylesheet" href="boot.css">\n<script src="boot.js"></script>\n<div id="boot-screen"></div>\n' "$f"
    fi
done

echo "[ZDOS BOOT] Injection OK"

############################################
# 4. COMMIT + PUSH
############################################

git add -A
git commit -m "ZDOS BOOT: added boot sequence to all pages"
git push

echo "[ZDOS BOOT] Completed"
