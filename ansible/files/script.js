document.addEventListener("DOMContentLoaded", () => {
    // On va chercher le fichier data.json
    fetch('data.json')
        .then(response => response.json())
        .then(data => {
            // 1. Mise à jour de l'en-tête
            document.getElementById('main-title').textContent = data.titre;
            document.getElementById('main-desc').textContent = data.description;

            // 2. Création des cartes pour chaque TP
            const container = document.getElementById('tp-container');

            data.tps.forEach(tp => {
                // Création de la carte
                const card = document.createElement('div');
                card.className = 'card';

                // Création des petits tags pour les outils
                const tagsHtml = tp.outils.map(outil => `${outil}`).join('');

                // Injection du contenu
                card.innerHTML = `
                    ${tp.numero}
                    ${tp.nom}
                    ${tagsHtml}
                    ${tp.description}
                `;

                // Ajout de la carte sur la page
                container.appendChild(card);
            });
        })
        .catch(error => {
            console.error("Erreur lors du chargement des données:", error);
            document.getElementById('main-desc').textContent = "Erreur de chargement des données.";
        });
});
