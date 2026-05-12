# Audio assets

The supervisor podium plays an applause sound that is resolved in this
order at runtime:

1. **Local file** — drop a file at this path: `sounds/applause.mp3`
   (relative to the site root, served at `/sounds/applause.mp3`).
2. **Shared Supabase storage** — falls back to the public RPP project
   bucket (`son/emircanalp-applause-alks-ses-efekti-125030.mp3`).
3. **Procedural fallback** — synthesized claps + crowd noise via WebAudio
   if neither of the above can be played.

Source #2 ensures the supervisor podium has a real applause sound out
of the box, without any setup. Drop a file at #1 to override it with
your own audio if you want.

A dedicated `sounds` Storage bucket exists on the SSIAP Supabase project
(see migration 0012) for hosting custom audio uploads, but is currently
unused — the runtime falls back to the RPP-hosted file.

Recommended length: 3 to 5 seconds. Any browser-supported format works.
