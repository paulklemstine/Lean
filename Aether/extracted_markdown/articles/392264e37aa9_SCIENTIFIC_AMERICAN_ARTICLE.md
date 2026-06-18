# The Infinite Beat: How an Algorithm Learned to Hack Your Brain with Music

*A new browser-based music engine generates endless electronic music across 25 genres — and uses neuroscience to make it feel impossibly good*

---

**By the Ecstasis Laboratory**

---

Close your eyes. A deep, sub-bass pulse rises through your chest like a second heartbeat. A crystalline arpeggio spirals upward, each note pulling you forward. The hi-hats accelerate, the filter sweeps open, and then — the drop. Your pupils dilate. Dopamine floods your nucleus accumbens. You feel something ancient and electric.

No human composed this music. No one pressed play on a track. The sound pouring through your headphones was born milliseconds ago inside a web browser, conjured by an algorithm called **Ecstasis 5** — and it was specifically engineered to make your brain do exactly what it just did.

## The Problem with Infinite Music

The dream of an infinite jukebox is old. Brian Eno coined the term "generative music" in 1996, imagining systems that would produce endlessly varying compositions the way a garden produces endlessly varying arrangements of flowers. But most generative music systems have a fatal flaw: they don't *feel* right. They either sound randomly noodling (too much chaos) or robotically repetitive (too much order). They lack the invisible architecture that makes a great DJ set feel like a journey — the tension that builds, the release that hits, the way the bass disappears and then comes back *heavier*.

Ecstasis 5 attacks this problem from both directions: algorithmic composition grounded in music theory, and psychoacoustic techniques grounded in neuroscience.

## How It Works: Music Theory Meets Code

At its core, Ecstasis 5 is a real-time synthesizer running in your web browser — no downloads, no plugins, no cloud processing. It generates sound from pure mathematics using the Web Audio API, an interface that gives JavaScript direct access to audio oscillators, filters, and effects processors.

The system operates on four levels simultaneously:

**Level 1: Sound Design.** Six synthesizer voices operate in parallel — kick drum, snare, hi-hat, bass, lead melody, and atmospheric pads. Each voice is built from first principles: the kick drum, for instance, is a sine wave that starts at 150 Hz and sweeps down to 30 Hz in 120 milliseconds, with a square-wave transient click layered on top. This mimics the physics of a real drum membrane, compressed and processed through the electronic music production techniques that have evolved since Roland released the TR-808 in 1980.

**Level 2: Music Theory.** The engine doesn't choose notes at random. It operates within a scale system encompassing 14 modes — from the bright Lydian mode used for ambient textures to the dark Phrygian mode that gives industrial and EBM their menacing character. Chord progressions follow nine distinct harmonic templates, each producing a different emotional trajectory. The classic pop progression (I–vi–IV–V) creates warmth and familiarity. The "tension" progression (i–♭II–V7–i°) creates unease and anticipation. Melodies walk through the scale using constrained Brownian motion — random, but tethered to the harmonic framework, producing the kind of stepwise motion that the human auditory cortex finds most naturally singable.

**Level 3: Genre DNA.** Each of the 25 genres is defined by a 14-dimensional parameter vector that captures its essential sonic identity. Techno: 132 BPM, minor scale, four-on-the-floor kick, heavy sub-bass, low filter cutoff. Lo-fi: 85 BPM, pentatonic scale, boom-bap drum pattern, warm filter, high swing. These aren't approximations — they're the quantified DNA of each genre, distilled from decades of electronic music evolution.

**Level 4: Arrangement.** This is where Ecstasis 5 diverges from most generative music systems. Instead of producing a flat, undifferentiated stream of sound, it implements macro-structural composition: intro → build → drop → breakdown → build → drop → outro. During a build, the filter cutoff sweeps upward from 800 Hz, creating the characteristic "rising" sensation. At the drop, all voices engage at full intensity, patterns regenerate with fresh variations, and the full frequency spectrum opens. During breakdowns, drums recede, pads swell, and the system creates the breathing space that makes the next build feel urgent.

This four-level architecture produces music that isn't just technically correct — it tells a *story*.

## The Neuroscience of the Drop

Why does a well-timed drop in an electronic music track produce such intense physical pleasure? The answer lies in a phenomenon neuroscientists call *prediction error*.

Your brain is a prediction machine. When you listen to music, your auditory cortex is constantly forecasting what comes next — the next beat, the next chord, the next note. When the prediction is confirmed, you experience a small reward signal. But when the music *violates* your prediction in a pleasing way — when the beat drops after a long build, when a chord resolves after sustained tension — the reward signal is dramatically amplified. Neuroscientist Valorie Salimpoor and her colleagues demonstrated this in a landmark 2011 study: using PET scans, they showed that the nucleus accumbens releases dopamine not just *during* peak musical moments, but *in anticipation* of them.

Ecstasis 5 is engineered to exploit this mechanism. Its arrangement engine creates systematic cycles of tension and release. During build phases, it gradually increases harmonic density and rhythmic complexity while restricting the frequency spectrum (the filter sweep), creating a growing sense of anticipation. At the drop, it delivers the prediction-confirming release — but with enough variation (chaos-modulated pattern regeneration) to keep the prediction errors coming.

"The key insight," explains the design philosophy behind the system, "is that maximum pleasure occurs not at peak stimulation, but at the *transition* from low to high arousal." This principle, first articulated by psychologist Daniel Berlyne in 1971, is the fundamental law of the Ecstasis 5 arrangement engine.

## Binaural Beats: Hacking Brainwaves Through Headphones

Perhaps the most provocative feature of Ecstasis 5 is its binaural beat generator. The system plays a continuous 200 Hz tone in your left ear and a slightly different frequency — say, 210 Hz — in your right ear. Your brain perceives the difference as a pulsating "beat" at 10 Hz, even though no 10 Hz tone exists in the audio signal. This phantom beat, arising from the interference pattern between the two tones processed in the superior olivary complex, can influence your own brainwave frequencies through a process called neural entrainment.

The science is tantalizing if not yet conclusive. A 10 Hz binaural beat targets the alpha brainwave band, associated with relaxed focus — the state in which creative insight most readily occurs. Adjusting the frequency difference to 25 Hz targets beta waves, promoting alertness and energy. At 40 Hz, gamma-band entrainment has been linked to enhanced cognitive processing and even the subjective experience of "flow."

Ecstasis 5 lets users tune this parameter from 1 to 40 Hz, effectively selecting their target brainwave state. Combined with the sub-bass frequencies that vibrate through the listener's chest cavity — stimulating the vestibular system and creating a visceral, physical connection to the music — the neuroacoustic layer adds a dimension to the listening experience that goes beyond what the ears alone can process.

## The Infinite Jukebox

Enable Auto-Mix mode, and Ecstasis 5 becomes something unprecedented: a music system that never repeats, never stops, and never gets boring.

Every 32 bars — roughly every 60 to 120 seconds — the system autonomously transitions to a new genre. House dissolves into psytrance. Psytrance morphs into lo-fi. Lo-fi transforms into drum and bass. Each transition respects the musical grammar of both the departing and arriving genres, using build phases as natural bridges between styles.

Within each genre, no two passes are identical. Melodic lines walk through different paths in the scale space. Drum patterns mutate under the influence of the chaos parameter. Filter sweeps vary. Chord progressions cycle through different voicings. The system generates, conservatively, millions of unique musical phrases per hour of operation — enough to run continuously for longer than any human lifetime without exact repetition.

## What It Means

Ecstasis 5 is not going to replace human musicians or DJs. It cannot write lyrics, tell a personal story, or respond to the energy of a live crowd with the intuition of a performer who has spent decades reading dance floors. What it demonstrates is something different and, in its own way, profound: that the mathematical structures underlying musical pleasure are regular enough to be formalized, parameterized, and automated.

The implications extend beyond entertainment. If we can algorithmically generate music that maximizes engagement and hedonic response, what does that tell us about the nature of musical experience itself? Is our profound, seemingly ineffable response to a well-crafted beat really just dopamine responding to statistical regularities? Or does the fact that we can describe the mechanism in no way diminish the magic of the experience — just as understanding photon wavelengths doesn't make a sunset less beautiful?

Press play. Close your eyes. Let the algorithm take you somewhere new. The infinite beat is waiting.

---

*Ecstasis 5 is an open-source, browser-based application. No installation required — just open the HTML file and press play.*

---

### Sidebar: The Numbers Behind the Sound

| Metric | Value |
|--------|-------|
| Genres supported | 25 |
| Musical scales | 14 |
| Chord types | 12 |
| Progression templates | 9 |
| Rhythmic archetypes | 10 |
| Concurrent synth voices | 7 |
| Binaural frequency range | 1–40 Hz |
| Audio latency | < 10 ms |
| Code size | Single HTML file |
| Dependencies | Zero (pure Web Audio API) |

### Sidebar: How to Use Ecstasis 5 for Maximum Effect

1. **Use headphones.** Binaural beats require stereo separation to work. Speakers won't produce the entrainment effect.
2. **Start with Alpha.** Set the Binaural Δ to 10 Hz for relaxed focus. Increase to 25+ Hz for high-energy genres.
3. **Enable Auto-Mix.** The genre transitions exploit the novelty-seeking dopamine response — each switch is a mini prediction error.
4. **Increase Hypnosis gradually.** The hypnosis parameter amplifies the binaural and visual entrainment effects. Start low.
5. **Let it run.** The system's arrangement engine needs at least 2–3 full phase cycles to establish the tension–release pattern. Give it five minutes before you judge it.
6. **Dim the lights.** The visual system includes a hypnotic spiral designed for peripheral visual entrainment. It works best in low ambient light.
