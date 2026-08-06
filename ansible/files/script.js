document.addEventListener("DOMContentLoaded", () => {
    let allData = [];

    // 1. Récupération des données JSON
    fetch('data.json')
        .then(response => response.json())
        .then(data => {
            allData = data.tps;
            document.getElementById('main-title').textContent = data.titre;
            document.getElementById('main-desc').textContent = data.description;
            document.getElementById('author-name').textContent = data.auteur;

            renderCards(allData);
        })
        .catch(error => console.error("Erreur de chargement JSON:", error));

    // 2. Fonction pour dessiner les cartes
    function renderCards(tps) {
        const container = document.getElementById('tp-container');
        container.innerHTML = '';

        tps.forEach(tp => {
            const card = document.createElement('div');
            card.className = 'card';
            card.dataset.outils = tp.outils.join(',');

            const tagsHtml = tp.outils.map(outil => `${outil}`).join('');

            card.innerHTML = `
                ${tp.numero}
                ${tp.nom}
                ${tagsHtml}
                ${tp.description}
            `;

            // Événement clic pour ouvrir la pop-up
            card.addEventListener('click', () => openModal(tp));
            container.appendChild(card);
        });
    }

    // 3. Gestion des filtres
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            // Gérer la classe active
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');

            const filter = e.target.dataset.filter;
            if (filter === 'all') {
                renderCards(allData);
            } else {
                const filtered = allData.filter(tp => tp.outils.includes(filter));
                renderCards(filtered);
            }
        });
    });

    // 4. Gestion de la Pop-up (Modale)
    const modal = document.getElementById('modal');
    const closeModal = document.querySelector('.close-modal');

    function openModal(tp) {
        document.getElementById('modal-numero').textContent = tp.numero;
        document.getElementById('modal-title').textContent = tp.nom;
        document.getElementById('modal-desc').textContent = tp.description;
        document.getElementById('modal-details').textContent = tp.details;

        document.getElementById('modal-tags').innerHTML = tp.outils.map(outil => `${outil}`).join('');

        modal.style.display = 'block';
    }

    closeModal.onclick = () => modal.style.display = 'none';
    window.onclick = (event) => {
        if (event.target == modal) modal.style.display = 'none';
    };

    // 5. Simulateur de Terminal
    document.getElementById('run-deploy').addEventListener('click', () => {
        const screen = document.getElementById('terminal-screen');
        screen.innerHTML = '';
        document.getElementById('run-deploy').disabled = true;

        const logs = [
            { text: "> aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running'", class: "" },
            { text: "[OK] 1 instance détectée (t2.micro)", class: "log-info" },
            { text: "> ping -c 1 localhost", class: "" },
            { text: "[OK] Réseau interne fonctionnel", class: "log-success" },
            { text: "> systemctl status nginx", class: "" },
            { text: "[OK] Service Nginx actif (running)", class: "log-success" },
            { text: "> trivy fs /var/www/html", class: "" },
            { text: "[OK] 0 vulnérabilités critiques trouvées", class: "log-info" },
            { text: "Diagnostic terminé. Tous les systèmes sont au vert.", class: "log-success" }
        ];

        let delay = 0;
        logs.forEach(log => {
            setTimeout(() => {
                screen.innerHTML += `${log.text}`;
                screen.scrollTop = screen.scrollHeight; // Auto-scroll
            }, delay);
            delay += 600 + Math.random() * 800; // Délai aléatoire pour faire vrai
        });

        setTimeout(() => { document.getElementById('run-deploy').disabled = false; }, delay);
    });
});
