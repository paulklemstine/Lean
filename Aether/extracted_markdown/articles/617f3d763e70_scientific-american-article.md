# The Algorithm That Never Stops Dancing

### A single web page generates infinite electronic music — no recordings, no AI models, just math and psychoacoustics

*By the ÆTHER Research Team*

---

When you press play, nothing loads. There are no audio files to download, no streaming buffers to fill. Instead, the machine *thinks* — and a fraction of a second later, a kick drum hits your chest like a fist wrapped in velvet. A bass line uncoils beneath it, dark and heavy. Hi-hats skitter across the stereo field. A pad drifts in like fog over a city at 3 AM.

This is ÆTHER, and every sound you're hearing was just invented. Right now. From nothing but mathematics.

## The Infinite Jukebox Problem

Here's a challenge that sounds simple: make a computer generate electronic music, live, forever, and make it *good*. Not "interesting as an experiment" good. Actually-want-to-listen-to-it good. Want-to-dance-to-it good.

The history of algorithmic music is long — Mozart designed a dice game to generate waltzes in 1787 — but most generative systems produce output that's either repetitive enough to bore you in 30 seconds or chaotic enough to give you a headache in 10. Electronic music, with its loops and drops and four-on-the-floor beats, seems like it should be easy for a computer. It's practically algorithmic already, right?

Wrong. The apparent simplicity hides enormous complexity. A good dubstep track isn't just a beat with bass on top — it's an architecture of tension and release, built from hundreds of small decisions about when to add a ghost note on the hi-hat, when to let the bass growl an octave lower, when to strip everything away to a single reverb tail before slamming the drop back in.

ÆTHER tries to encode all of those decisions into a system that fits in a single web page.

## Synthesizing Reality

The first surprise: ÆTHER uses no audio samples whatsoever. Every sound — every kick drum, snare crack, shimmering hi-hat, growling bass, ethereal pad — is constructed in real time from basic waveforms: sine waves, sawtooth waves, square waves, and noise.

A kick drum, for instance, is built from three layers:

1. A **sine wave** that starts at 150 Hz and swoops down to 30 Hz in 80 milliseconds — this creates the deep "thump" you feel in your chest.
2. A **square wave** that starts at 2,500 Hz and crashes down to 100 Hz in 20 milliseconds — the sharp "click" of the beater hitting the drumhead.
3. A **waveshaper** that distorts the combined signal, adding harmonics that give the kick its character — clean and round for house music, crunchy and aggressive for hardwave.

This layered approach to sound design means the system can produce kick drums that are genuinely different across genres, not just the same sound with different effects. A techno kick sounds like a techno kick. A trap 808 sounds like a trap 808. All from sine waves and math.

## 28 Genres, One Engine

ÆTHER currently knows 28 electronic music genres, from ambient to footwork, from lo-fi hip-hop to psytrance. Each genre is defined by a parameter vector — a set of numbers that encode everything the system needs to know:

- **Tempo range:** 70 BPM for ambient, 180 BPM for drum & bass
- **Scale:** Phrygian mode for dark genres like dubstep and phonk; Dorian for the warmth of deep house; Phrygian Dominant (the "Hijaz" scale of Middle Eastern music) for the eerie exotic feel of phonk
- **Drum patterns:** Templates for kick, snare, and hi-hat placement on a 16-step grid
- **Bass synthesis type:** Wobble, acid, reese, 808, supersaw — twelve distinct algorithms
- **Swing:** 0% for the rigid grid of techno, 18% for the slouchy groove of lo-fi
- **Energy, density, darkness:** Floating-point knobs that shape the overall character

This parameterization is the core innovation. It means that "dubstep" and "house" aren't separate programs — they're different coordinates in the same musical space. And the system can smoothly navigate between them.

## The Architecture of Ecstasy

Electronic music isn't just notes and rhythms. It's a *psychological technology* — a system for manipulating human emotional states. And ÆTHER's designers took that seriously.

### The Buildup-Drop Mechanism

Every EDM fan knows the feeling: the music strips down to a filtered whisper, a snare roll begins to intensify, the filter opens like a flower blooming in fast-forward — and then **the drop hits**.

This isn't just exciting music. Neuroscientists at McGill University have shown that the buildup-drop mechanism triggers dopamine release in the brain's reward circuits — the same circuits activated by food, sex, and addictive drugs. The anticipation during the buildup *is the drug*. The brain's prediction systems go into overdrive, modeling what the drop will sound like, and the gap between prediction and reality creates a spike of neural pleasure.

ÆTHER implements this with a seven-section song structure: Intro → Buildup → Drop → Breakdown → Buildup 2 → Drop 2 → Outro. During buildups, the low-pass filter sweeps upward (progressively revealing higher frequencies), pattern density increases (more hi-hat subdivisions, added percussion), and harmonic tension builds (dominant seventh chords, tritone intervals). At the drop, the filter opens fully, the kick and bass slam in at maximum energy, and sidechain compression creates the visceral "pumping" sensation.

### Rhythmic Entrainment

Your brain wants to synchronize with regular beats. This is "entrainment" — a phenomenon where neural oscillators lock onto periodic stimuli. It's why you tap your foot, why you nod your head, why a room full of strangers at a rave can move as one organism.

ÆTHER keeps all tempos within the window where entrainment is strongest: 70–180 BPM, corresponding to periodicities of 0.33–1.17 seconds. These overlap with natural human motor rhythms — walking, breathing, heartbeats. The system essentially *hacks* your motor cortex into synchronizing with its output.

### Hypnotic Repetition

There's a reason techno DJs play the same four-bar loop for three minutes straight. Repetition, research shows, doesn't just create familiarity — it alters consciousness. Ethnomusicologist Gilbert Rouget documented in 1985 how repetitive rhythmic sound is used across cultures to induce trance states, from Haitian voodoo ceremonies to Sufi dhikr to Detroit techno warehouses.

ÆTHER has a "Hypnosis" parameter that controls the ratio of repetition to variation. At high settings, patterns repeat with minimal variation, filter modulations slow down, and the music becomes a pulsing, meditative loop — what techno producer Jeff Mills calls "music for the mind to float in."

### Sub-Bass and the Body

Below about 80 Hz, you don't just *hear* sound — you *feel* it. Research by Neil Todd at the University of Manchester showed that low-frequency sound stimulates the vestibular system (the balance organs in your inner ear), creating sensations of physical movement and spatial disorientation. This is why bass-heavy music at high volumes literally makes you feel like you're floating.

ÆTHER's sub-bass synthesis specifically targets the 30–60 Hz range where vestibular sensitivity peaks. The 808-style bass of trap, the sub oscillator of dubstep, the deep kick drums of techno — all are engineered to cross the threshold from auditory perception to somatic experience.

## The Chaos Dial

One of ÆTHER's most interesting controls is the "Chaos" parameter. At 0%, the output is rigidly quantized to the grid and the scale — perfectly in time, perfectly in key, perfectly predictable. At 100%, ghost notes appear randomly, drum patterns fragment, melodic lines leap unpredictably, and the music begins to sound like a machine having a creative breakdown.

The sweet spot — where the music is most *alive* — tends to be around 25-40%. This corresponds to what information theorists call the "edge of chaos": the boundary between order and disorder where complex systems exhibit maximum computational capacity. It's also, not coincidentally, where human musicians tend to operate. A perfectly quantized drum performance sounds mechanical; one with 10-20% timing variation sounds *human*.

This connects to a deeper principle: complexity emerges from the interaction of simple rules with randomness. ÆTHER's patterns are generated by algorithms that are individually simple — "place a note on this beat with probability P, chosen from this scale" — but whose interactions produce emergent structure that can surprise even the system's designers.

## Inside the Machine

Technically, ÆTHER runs entirely in your web browser. It uses the Web Audio API, a standard browser feature that provides low-level audio processing capabilities. The system creates an audio processing graph:

```
Synthesizers → Sidechain → Distortion → Filter → Reverb/Delay → Compressor → Speakers
```

Every node in this graph is doing real-time mathematics. The reverb, for example, isn't a recording of a real room — it's a convolution with an algorithmically generated impulse response (basically: multiply the music by a specific noise pattern that simulates how sound bounces around an imaginary space).

The timing system uses a "look-ahead" scheduler that works around JavaScript's non-real-time limitations. Rather than trying to generate each note at the exact millisecond it needs to play (impossible in a garbage-collected language), the system schedules notes about 100 milliseconds into the future, using the Web Audio API's sample-accurate clock. This gives rock-solid timing despite running in a browser tab.

## What It Means

ÆTHER is not going to replace human producers. It can't write lyrics. It can't make creative decisions that surprise and delight the way a talented artist can. It doesn't understand what a song *means*.

But it does demonstrate something remarkable: how much of music's emotional power comes from *structure* rather than *content*. The buildup-drop mechanism works whether the drop is a dubstep wobble bass or a trance supersaw — because the emotional impact comes from the tension-release pattern, not the specific notes. A minor-key chord progression creates a dark mood whether it's played by a symphony orchestra or a sawtooth oscillator.

And it raises fascinating questions. If an algorithm can make you feel ecstatic by manipulating tempo, timbre, and tension, what does that say about the nature of musical emotion? Are we moved by art, or by patterns? Is the DJ an artist or an engineer?

Perhaps the answer is: there was never a difference.

---

*ÆTHER is available as a free, open-source web application. Press Play and dance.*
