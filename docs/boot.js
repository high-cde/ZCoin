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
