insert into public.lieux (
  id,
  nom,
  description,
  latitude,
  longitude,
  heure_ouverture,
  heure_fermeture,
  image_url,
  categorie,
  is_validated
)
values
  (
    'parc-street-workout',
    'Parc de street workout',
    'Espace exterieur pour sport libre et entrainement au poids du corps.',
    50.323449622706676,
    3.51328894643105,
    '00:00',
    '00:00',
    'https://lh3.googleusercontent.com/gps-cs-s/APNQkAErTV6pIvnUuTahu-6euLk9Ch3rxHh2-oY4uQEBcFIzK1vMIzCEMx47wbH0f58A4VKG0u13vvIZbBi6IhcPdTRZQIhQAJSp00Ej_gZNHKheX_jMrqscxKa91rweJGNxZErXrTYw=s1360-w1360-h1020-rw',
    'sport',
    true
  ),
  (
    'le-sphimx',
    'Le Sphimx',
    'Association des étudiants en licence de l''UPHF',
    50.32151068086321,
    3.513607706626061,
    '08:45',
    '19:30',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLotmnSqenxqEuyybUycet04cRqKP9biHfjQ&s',
    'associations',
    true
  ),
  (
    '1',
    'RU Mont Houy 2',
    'Le meilleur RU du campus',
    50.322685392872394,
    3.512991191805414,
    '11:15',
    '13:30',
    '',
    'repas',
    true
  )
on conflict (id) do update
set
  nom = excluded.nom,
  description = excluded.description,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  heure_ouverture = excluded.heure_ouverture,
  heure_fermeture = excluded.heure_fermeture,
  image_url = excluded.image_url,
  categorie = excluded.categorie,
  is_validated = excluded.is_validated;
