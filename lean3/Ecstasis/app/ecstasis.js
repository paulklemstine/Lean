// ═══════════════════════════════════════════════════════════════════
// ECSTASIS — Infinite Algorithmic Dance Music Engine
// ═══════════════════════════════════════════════════════════════════
// A real-time generative music system using Web Audio API.
// Synthesizes electronic dance music across multiple genres using
// Euclidean rhythms, Markov chains, Perlin noise automation,
// and psychoacoustic techniques.
// ═══════════════════════════════════════════════════════════════════

(function() {
"use strict";

// ─── MUSIC THEORY CONSTANTS ─────────────────────────────────────
const NOTE_NAMES = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
const SCALES = {
    minor:             [0,2,3,5,7,8,10],
    dorian:            [0,2,3,5,7,9,10],
    phrygian:          [0,1,3,5,7,8,10],
    phrygianDominant:  [0,1,4,5,7,8,10],
    harmonicMinor:     [0,2,3,5,7,8,11],
    melodicMinor:      [0,2,3,5,7,9,11],
    minorPentatonic:   [0,3,5,7,10],
    blues:             [0,3,5,6,7,10],
    major:             [0,2,4,5,7,9,11],
    mixolydian:        [0,2,4,5,7,9,10],
    lydian:            [0,2,4,6,7,9,11],
    wholeTone:         [0,2,4,6,8,10],
    locrian:           [0,1,3,5,6,8,10],
    chromatic:         [0,1,2,3,4,5,6,7,8,9,10,11]
};

// Chord templates (intervals from root)
const CHORDS = {
    min:   [0,3,7],
    maj:   [0,4,7],
    min7:  [0,3,7,10],
    maj7:  [0,4,7,11],
    dom7:  [0,4,7,10],
    sus4:  [0,5,7],
    sus2:  [0,2,7],
    dim:   [0,3,6],
    aug:   [0,4,8],
    power: [0,7,12]
};

// ─── GENRE PROFILES ─────────────────────────────────────────────
const GENRES = {
    house: {
        name: 'House', bpm: [120,130], defaultBpm: 124,
        scales: ['dorian','minor','mixolydian'],
        chordTypes: ['min7','maj7','dom7','sus4'],
        progressions: [[0,5,3,4],[0,3,5,4],[0,5,0,4],[0,0,3,4]],
        kickPattern: {k:4,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:8,n:16}, hatOpen: {k:2,n:16,offset:2},
        percPattern: {k:3,n:16},
        swing: 0.15, bassType: 'sine', bassOctave: 2,
        leadType: 'square', padType: 'sawtooth',
        filterBase: 3000, filterRange: 6000, reverbAmt: 0.3,
        delayTime: 0.375, delayFeedback: 0.25, delayAmt: 0.2,
        distortion: 0, energy: 0.65,
        color: '#ff9500'
    },
    techno: {
        name: 'Techno', bpm: [128,145], defaultBpm: 135,
        scales: ['phrygian','locrian','minor','chromatic'],
        chordTypes: ['power','sus4','min','dim'],
        progressions: [[0,0,0,0],[0,0,3,0],[0,0,0,5],[0,3,0,5]],
        kickPattern: {k:4,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:12,n:16}, hatOpen: {k:1,n:16,offset:6},
        percPattern: {k:5,n:16},
        swing: 0.0, bassType: 'sawtooth', bassOctave: 2,
        leadType: 'sawtooth', padType: 'sawtooth',
        filterBase: 800, filterRange: 8000, reverbAmt: 0.4,
        delayTime: 0.25, delayFeedback: 0.4, delayAmt: 0.3,
        distortion: 20, energy: 0.75,
        color: '#888888'
    },
    dubstep: {
        name: 'Dubstep', bpm: [138,142], defaultBpm: 140,
        scales: ['phrygianDominant','minor','minorPentatonic','phrygian'],
        chordTypes: ['power','min','dim','sus4'],
        progressions: [[0,0,5,4],[0,3,5,0],[0,0,0,4],[0,5,3,4]],
        kickPattern: {k:2,n:16}, snarePattern: {k:1,n:8,offset:3},
        hatPattern: {k:4,n:16}, hatOpen: {k:1,n:8,offset:5},
        percPattern: {k:3,n:16},
        swing: 0.0, bassType: 'sawtooth', bassOctave: 1,
        leadType: 'square', padType: 'sawtooth',
        filterBase: 500, filterRange: 10000, reverbAmt: 0.2,
        delayTime: 0.5, delayFeedback: 0.2, delayAmt: 0.15,
        distortion: 60, energy: 0.85,
        color: '#7b2fff'
    },
    phonk: {
        name: 'Phonk', bpm: [130,160], defaultBpm: 140,
        scales: ['minorPentatonic','blues','minor'],
        chordTypes: ['min','power','min7','dim'],
        progressions: [[0,0,5,4],[0,6,5,4],[0,3,0,4],[0,0,3,0]],
        kickPattern: {k:3,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:10,n:16}, hatOpen: {k:3,n:16,offset:2},
        percPattern: {k:6,n:16}, // cowbell-like
        swing: 0.05, bassType: 'sine', bassOctave: 1,
        leadType: 'square', padType: 'triangle',
        filterBase: 2000, filterRange: 5000, reverbAmt: 0.15,
        delayTime: 0.333, delayFeedback: 0.15, delayAmt: 0.1,
        distortion: 40, energy: 0.7,
        color: '#cc0000'
    },
    wave: {
        name: 'Wave', bpm: [140,160], defaultBpm: 150,
        scales: ['lydian','minor','wholeTone','harmonicMinor'],
        chordTypes: ['maj7','min7','sus2','aug'],
        progressions: [[0,4,5,3],[0,2,5,4],[0,5,3,2],[0,0,4,5]],
        kickPattern: {k:2,n:16}, snarePattern: {k:1,n:8,offset:3},
        hatPattern: {k:6,n:16}, hatOpen: {k:2,n:16,offset:4},
        percPattern: {k:3,n:16},
        swing: 0.05, bassType: 'triangle', bassOctave: 2,
        leadType: 'sine', padType: 'sine',
        filterBase: 5000, filterRange: 5000, reverbAmt: 0.6,
        delayTime: 0.5, delayFeedback: 0.45, delayAmt: 0.4,
        distortion: 0, energy: 0.45,
        color: '#00aaff'
    },
    ebm: {
        name: 'EBM', bpm: [110,140], defaultBpm: 125,
        scales: ['minor','harmonicMinor','phrygian'],
        chordTypes: ['min','power','dim','sus4'],
        progressions: [[0,0,3,4],[0,0,0,5],[0,4,3,0],[0,5,0,4]],
        kickPattern: {k:4,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:8,n:16}, hatOpen: {k:1,n:16,offset:6},
        percPattern: {k:4,n:16},
        swing: 0.0, bassType: 'sawtooth', bassOctave: 2,
        leadType: 'sawtooth', padType: 'square',
        filterBase: 1500, filterRange: 6000, reverbAmt: 0.2,
        delayTime: 0.25, delayFeedback: 0.3, delayAmt: 0.2,
        distortion: 35, energy: 0.75,
        color: '#ff4400'
    },
    edm: {
        name: 'EDM', bpm: [126,132], defaultBpm: 128,
        scales: ['major','mixolydian','minor','lydian'],
        chordTypes: ['maj','min','sus4','maj7'],
        progressions: [[0,5,3,4],[0,3,5,4],[0,4,5,3],[0,5,0,4]],
        kickPattern: {k:4,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:8,n:16}, hatOpen: {k:4,n:16,offset:2},
        percPattern: {k:5,n:16},
        swing: 0.0, bassType: 'sawtooth', bassOctave: 2,
        leadType: 'sawtooth', padType: 'sawtooth',
        filterBase: 4000, filterRange: 8000, reverbAmt: 0.35,
        delayTime: 0.375, delayFeedback: 0.3, delayAmt: 0.25,
        distortion: 10, energy: 0.8,
        color: '#00ff88'
    },
    trance: {
        name: 'Trance', bpm: [136,150], defaultBpm: 140,
        scales: ['minor','harmonicMinor','phrygian','melodicMinor'],
        chordTypes: ['min','min7','sus4','sus2'],
        progressions: [[0,5,3,4],[0,3,5,4],[0,2,5,4],[0,5,0,3]],
        kickPattern: {k:4,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:12,n:16}, hatOpen: {k:4,n:16,offset:2},
        percPattern: {k:5,n:16},
        swing: 0.0, bassType: 'sawtooth', bassOctave: 2,
        leadType: 'sawtooth', padType: 'sawtooth',
        filterBase: 3000, filterRange: 8000, reverbAmt: 0.45,
        delayTime: 0.375, delayFeedback: 0.35, delayAmt: 0.3,
        distortion: 5, energy: 0.75,
        color: '#aa00ff'
    },
    dnb: {
        name: 'Drum & Bass', bpm: [170,180], defaultBpm: 174,
        scales: ['dorian','minor','minorPentatonic'],
        chordTypes: ['min7','min','sus2','dom7'],
        progressions: [[0,5,3,4],[0,3,0,4],[0,0,5,3],[0,5,0,5]],
        kickPattern: {k:3,n:16}, snarePattern: {k:2,n:16,offset:4},
        hatPattern: {k:10,n:16}, hatOpen: {k:3,n:16,offset:3},
        percPattern: {k:6,n:16},
        swing: 0.08, bassType: 'sawtooth', bassOctave: 2,
        leadType: 'square', padType: 'triangle',
        filterBase: 2000, filterRange: 7000, reverbAmt: 0.25,
        delayTime: 0.214, delayFeedback: 0.3, delayAmt: 0.2,
        distortion: 25, energy: 0.85,
        color: '#ffaa00'
    },
    ambientTechno: {
        name: 'Ambient Techno', bpm: [100,122], defaultBpm: 112,
        scales: ['lydian','wholeTone','major','dorian'],
        chordTypes: ['maj7','sus2','min7','aug'],
        progressions: [[0,4,5,2],[0,2,5,0],[0,0,4,5],[0,5,2,4]],
        kickPattern: {k:3,n:16}, snarePattern: {k:1,n:16,offset:4},
        hatPattern: {k:5,n:16}, hatOpen: {k:2,n:16,offset:6},
        percPattern: {k:3,n:16},
        swing: 0.1, bassType: 'sine', bassOctave: 2,
        leadType: 'sine', padType: 'sine',
        filterBase: 4000, filterRange: 4000, reverbAmt: 0.65,
        delayTime: 0.5, delayFeedback: 0.5, delayAmt: 0.4,
        distortion: 0, energy: 0.35,
        color: '#0088aa'
    }
};

// ─── UTILITY FUNCTIONS ──────────────────────────────────────────

function midiToFreq(midi) { return 440 * Math.pow(2, (midi - 69) / 12); }
function rnd(a, b) { return a + Math.random() * (b - a); }
function rndInt(a, b) { return Math.floor(rnd(a, b + 1)); }
function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }
function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }
function lerp(a, b, t) { return a + (b - a) * t; }

// Bjorklund / Euclidean rhythm algorithm
function euclidean(k, n, offset = 0) {
    if (k >= n) return new Array(n).fill(1);
    if (k <= 0) return new Array(n).fill(0);
    let pattern = [];
    let counts = new Array(k).fill(1);
    let remainders = [];
    let level = 0;
    let divisor = n - k;
    remainders.push(k);
    while (true) {
        let newCounts = [];
        let newRemainders = [];
        let c = Math.floor(divisor / remainders[level]);
        let r = divisor % remainders[level];
        for (let i = 0; i < remainders[level]; i++) {
            counts[i] = counts[i] || 1;
        }
        if (r <= 1) break;
        divisor = remainders[level];
        remainders.push(r);
        level++;
    }
    // Build pattern using simplified approach
    pattern = buildEuclidean(k, n);
    // Apply rotation/offset
    if (offset > 0) {
        offset = offset % n;
        pattern = pattern.slice(n - offset).concat(pattern.slice(0, n - offset));
    }
    return pattern;
}

function buildEuclidean(k, n) {
    let pattern = [];
    let bucket = 0;
    for (let i = 0; i < n; i++) {
        bucket += k;
        if (bucket >= n) {
            bucket -= n;
            pattern.push(1);
        } else {
            pattern.push(0);
        }
    }
    return pattern;
}

// Perlin noise (simplified 1D)
class PerlinNoise {
    constructor() {
        this.perm = [];
        for (let i = 0; i < 256; i++) this.perm.push(i);
        for (let i = 255; i > 0; i--) {
            let j = Math.floor(Math.random() * (i + 1));
            [this.perm[i], this.perm[j]] = [this.perm[j], this.perm[i]];
        }
        this.perm = this.perm.concat(this.perm);
    }
    fade(t) { return t * t * t * (t * (t * 6 - 15) + 10); }
    grad(hash, x) { return (hash & 1) === 0 ? x : -x; }
    noise(x) {
        let xi = Math.floor(x) & 255;
        let xf = x - Math.floor(x);
        let u = this.fade(xf);
        let a = this.perm[xi];
        let b = this.perm[xi + 1];
        return lerp(this.grad(a, xf), this.grad(b, xf - 1), u);
    }
    octaveNoise(x, octaves = 4, persistence = 0.5) {
        let total = 0, frequency = 1, amplitude = 1, maxVal = 0;
        for (let i = 0; i < octaves; i++) {
            total += this.noise(x * frequency) * amplitude;
            maxVal += amplitude;
            amplitude *= persistence;
            frequency *= 2;
        }
        return total / maxVal;
    }
}

// ─── MARKOV CHAIN MELODY GENERATOR ─────────────────────────────

class MarkovMelody {
    constructor(scale, rootMidi) {
        this.scale = scale;
        this.root = rootMidi;
        this.buildTransitionMatrix();
        this.currentDegree = 0;
    }
    
    buildTransitionMatrix() {
        const n = this.scale.length;
        // Build transition probabilities favoring stepwise motion
        this.transitions = [];
        for (let i = 0; i < n; i++) {
            let probs = new Array(n).fill(0.02); // small base probability
            // Stepwise motion (most likely)
            probs[(i + 1) % n] += 0.3;
            probs[(i - 1 + n) % n] += 0.25;
            // Skip motion
            probs[(i + 2) % n] += 0.12;
            probs[(i - 2 + n) % n] += 0.1;
            // Return to root
            probs[0] += 0.08;
            // Leap to fifth
            let fifthIdx = this.scale.indexOf(7);
            if (fifthIdx === -1) fifthIdx = Math.floor(n / 2);
            probs[fifthIdx] += 0.06;
            // Normalize
            let sum = probs.reduce((a, b) => a + b, 0);
            this.transitions.push(probs.map(p => p / sum));
        }
    }
    
    next(octaveRange = 1) {
        const probs = this.transitions[this.currentDegree];
        let r = Math.random();
        let cumulative = 0;
        for (let i = 0; i < probs.length; i++) {
            cumulative += probs[i];
            if (r <= cumulative) {
                this.currentDegree = i;
                break;
            }
        }
        const octaveShift = rndInt(0, octaveRange) * 12;
        return this.root + this.scale[this.currentDegree] + octaveShift;
    }
    
    generatePhrase(length, octaveRange = 1) {
        let phrase = [];
        for (let i = 0; i < length; i++) {
            phrase.push(this.next(octaveRange));
        }
        return phrase;
    }
}

// ─── MAIN AUDIO ENGINE ──────────────────────────────────────────

class EcstasisEngine {
    constructor() {
        this.ctx = null;
        this.playing = false;
        this.bpm = 128;
        this.genre = GENRES.house;
        this.genreKey = 'house';
        
        // Scheduling
        this.nextNoteTime = 0;
        this.currentStep = 0;
        this.currentBar = 0;
        this.currentSection = 'intro';
        this.sectionBar = 0;
        this.sectionLength = 8;
        this.lookahead = 0.1; // seconds
        this.scheduleInterval = 25; // ms
        this.schedulerTimer = null;
        
        // Musical state
        this.rootNote = 36; // C2 MIDI
        this.rootKey = 0;   // C
        this.scale = SCALES.minor;
        this.chordProg = [0, 5, 3, 4];
        this.currentChordIdx = 0;
        this.tension = 0; // 0-1
        this.targetTension = 0;
        
        // Generators
        this.perlin = new PerlinNoise();
        this.melodyGen = null;
        this.arpGen = null;
        this.perlinTime = Math.random() * 1000;
        
        // Patterns (will be generated)
        this.kickPat = [];
        this.snarePat = [];
        this.hatPat = [];
        this.hatOpenPat = [];
        this.percPat = [];
        this.bassNotes = [];
        this.melodyNotes = [];
        this.arpNotes = [];
        
        // Audio nodes (created on init)
        this.masterGain = null;
        this.compressor = null;
        this.analyser = null;
        this.reverbNode = null;
        this.reverbGain = null;
        this.dryGain = null;
        this.delayNode = null;
        this.delayFeedback = null;
        this.delayGain = null;
        this.filterNode = null;
        
        // Channel gains
        this.gains = {};
        
        // Psychoacoustic
        this.psychEnabled = false;
        this.shepardEnabled = false;
        this.shepardOscs = [];
        this.binauralOscL = null;
        this.binauralOscR = null;
        this.binauralGain = null;
        
        // Auto DJ
        this.autoDJ = false;
        this.autoDJTimer = 0;
        
        // UI params
        this.params = {
            masterVol: 0.7,
            filterCut: 4000,
            filterRes: 5,
            distortion: 10,
            subBass: 70,
            reverbMix: 30,
            delayMix: 20,
            swing: 10,
            complexity: 50,
            mixKick: 85,
            mixSnare: 70,
            mixHat: 50,
            mixBass: 80,
            mixMelody: 55,
            mixPad: 40,
            mixArp: 35,
            mixFx: 25
        };
        
        // Section state machine
        this.sections = ['intro','build','drop','breakdown','build2','drop2','outro'];
        this.sectionWeights = {
            intro:     { build: 1.0 },
            build:     { drop: 1.0 },
            drop:      { breakdown: 0.7, drop: 0.3 },
            breakdown: { build2: 0.8, build: 0.2 },
            build2:    { drop2: 1.0 },
            drop2:     { breakdown: 0.5, drop: 0.3, outro: 0.2 },
            outro:     { intro: 1.0 }
        };
    }
    
    init() {
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        
        // Master chain: filter → compressor → gain → analyser → destination
        this.analyser = this.ctx.createAnalyser();
        this.analyser.fftSize = 2048;
        this.analyser.smoothingTimeConstant = 0.8;
        
        this.compressor = this.ctx.createDynamicsCompressor();
        this.compressor.threshold.value = -12;
        this.compressor.knee.value = 6;
        this.compressor.ratio.value = 4;
        this.compressor.attack.value = 0.005;
        this.compressor.release.value = 0.1;
        
        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.value = this.params.masterVol;
        
        this.filterNode = this.ctx.createBiquadFilter();
        this.filterNode.type = 'lowpass';
        this.filterNode.frequency.value = this.params.filterCut;
        this.filterNode.Q.value = this.params.filterRes;
        
        // Reverb using convolver with generated IR
        this.reverbNode = this.ctx.createConvolver();
        this.reverbNode.buffer = this.generateReverbIR(2, 2.5);
        this.reverbGain = this.ctx.createGain();
        this.reverbGain.gain.value = this.params.reverbMix / 100;
        this.dryGain = this.ctx.createGain();
        this.dryGain.gain.value = 1.0;
        
        // Delay
        this.delayNode = this.ctx.createDelay(2.0);
        this.delayNode.delayTime.value = 0.375;
        this.delayFeedback = this.ctx.createGain();
        this.delayFeedback.gain.value = 0.3;
        this.delayGain = this.ctx.createGain();
        this.delayGain.gain.value = this.params.delayMix / 100;
        
        // Routing
        // Source → filterNode → [dry + reverb + delay] → compressor → masterGain → analyser → dest
        this.filterNode.connect(this.dryGain);
        this.filterNode.connect(this.reverbNode);
        this.reverbNode.connect(this.reverbGain);
        this.filterNode.connect(this.delayNode);
        this.delayNode.connect(this.delayFeedback);
        this.delayFeedback.connect(this.delayNode);
        this.delayNode.connect(this.delayGain);
        
        this.dryGain.connect(this.compressor);
        this.reverbGain.connect(this.compressor);
        this.delayGain.connect(this.compressor);
        
        this.compressor.connect(this.masterGain);
        this.masterGain.connect(this.analyser);
        this.analyser.connect(this.ctx.destination);
        
        // Channel gains
        const channels = ['kick','snare','hat','bass','melody','pad','arp','fx','perc','sub'];
        channels.forEach(ch => {
            this.gains[ch] = this.ctx.createGain();
            this.gains[ch].connect(this.filterNode);
        });
        this.updateMixLevels();
        
        this.setGenre('house');
    }
    
    generateReverbIR(channels, duration) {
        const sampleRate = this.ctx.sampleRate;
        const length = sampleRate * duration;
        const buffer = this.ctx.createBuffer(channels, length, sampleRate);
        for (let ch = 0; ch < channels; ch++) {
            const data = buffer.getChannelData(ch);
            for (let i = 0; i < length; i++) {
                data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / length, 2.5);
            }
        }
        return buffer;
    }
    
    setGenre(key) {
        if (!GENRES[key]) return;
        this.genreKey = key;
        this.genre = GENRES[key];
        
        // Set BPM
        const bpmSlider = document.getElementById('bpmSlider');
        if (bpmSlider && !this.playing) {
            this.bpm = this.genre.defaultBpm;
            bpmSlider.value = this.bpm;
            document.getElementById('bpmDisplay').textContent = this.bpm;
        }
        
        // Choose random key and scale
        this.rootKey = rndInt(0, 11);
        this.scale = SCALES[pick(this.genre.scales)];
        this.rootNote = 36 + this.rootKey; // C2 + key offset
        this.chordProg = pick(this.genre.progressions);
        
        // Generate patterns
        this.regeneratePatterns();
        
        // Initialize melody generators
        this.melodyGen = new MarkovMelody(this.scale, this.rootNote + 24); // melody in octave 4
        this.arpGen = new MarkovMelody(this.scale, this.rootNote + 12);    // arp in octave 3
        
        // Generate melodic content for first section
        this.generateMelodicContent();
        
        // Apply genre effects
        if (this.playing) {
            this.filterNode.frequency.value = this.genre.filterBase;
            this.delayNode.delayTime.value = this.genre.delayTime;
            this.delayFeedback.gain.value = this.genre.delayFeedback;
        }
        
        // Update UI
        this.updateStatus();
        
        // Highlight genre button
        document.querySelectorAll('.genre-btn').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.querySelector(`.genre-btn[data-genre="${key}"]`);
        if (activeBtn) activeBtn.classList.add('active');
    }
    
    regeneratePatterns() {
        const g = this.genre;
        this.kickPat = euclidean(g.kickPattern.k, g.kickPattern.n);
        this.snarePat = euclidean(g.snarePattern.k, g.snarePattern.n, g.snarePattern.offset || 0);
        this.hatPat = euclidean(g.hatPattern.k, g.hatPattern.n);
        this.hatOpenPat = euclidean(g.hatOpen.k, g.hatOpen.n, g.hatOpen.offset || 0);
        this.percPat = euclidean(g.percPattern.k, g.percPattern.n);
    }
    
    generateMelodicContent() {
        // Bass line: root notes following chord progression
        this.bassNotes = [];
        for (let bar = 0; bar < 4; bar++) {
            let chordRoot = this.chordProg[bar];
            let scaleNote = this.scale[chordRoot % this.scale.length];
            let bassMidi = this.rootNote + scaleNote;
            // Generate bass pattern for bar
            let bassBar = [];
            for (let step = 0; step < 16; step++) {
                if (step === 0) {
                    bassBar.push(bassMidi);
                } else if (step === 8 && Math.random() > 0.5) {
                    bassBar.push(bassMidi + pick([0, 5, 7]));
                } else if (Math.random() > 0.85) {
                    bassBar.push(bassMidi + pick(this.scale.slice(0, 5)));
                } else {
                    bassBar.push(0); // rest
                }
            }
            this.bassNotes.push(bassBar);
        }
        
        // Melody phrase
        this.melodyNotes = [];
        for (let bar = 0; bar < 4; bar++) {
            let melBar = [];
            let phrase = this.melodyGen.generatePhrase(16, 1);
            for (let step = 0; step < 16; step++) {
                // Create rhythmic pattern for melody (not every step)
                if (Math.random() > 0.6) {
                    melBar.push(phrase[step]);
                } else {
                    melBar.push(0);
                }
            }
            this.melodyNotes.push(melBar);
        }
        
        // Arp pattern
        this.arpNotes = [];
        for (let bar = 0; bar < 4; bar++) {
            let arpBar = [];
            let chordRoot = this.chordProg[bar];
            let scaleNote = this.scale[chordRoot % this.scale.length];
            let arpRoot = this.rootNote + 12 + scaleNote;
            let chordType = pick(this.genre.chordTypes);
            let intervals = CHORDS[chordType];
            for (let step = 0; step < 16; step++) {
                if (step % 2 === 0 || Math.random() > 0.4) {
                    arpBar.push(arpRoot + intervals[step % intervals.length]);
                } else {
                    arpBar.push(0);
                }
            }
            this.arpNotes.push(arpBar);
        }
    }
    
    // ─── SYNTHESIS ──────────────────────────────────────────────
    
    playKick(time, velocity = 1.0) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(150, time);
        osc.frequency.exponentialRampToValueAtTime(40, time + 0.07);
        gain.gain.setValueAtTime(velocity * 0.9, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 0.4);
        osc.connect(gain);
        gain.connect(this.gains.kick);
        osc.start(time);
        osc.stop(time + 0.4);
        
        // Click transient
        const click = this.ctx.createOscillator();
        const clickGain = this.ctx.createGain();
        click.type = 'square';
        click.frequency.value = 800;
        clickGain.gain.setValueAtTime(velocity * 0.3, time);
        clickGain.gain.exponentialRampToValueAtTime(0.001, time + 0.01);
        click.connect(clickGain);
        clickGain.connect(this.gains.kick);
        click.start(time);
        click.stop(time + 0.02);
    }
    
    playSnare(time, velocity = 1.0) {
        // Noise component
        const noiseLen = 0.15;
        const bufSize = this.ctx.sampleRate * noiseLen;
        const buf = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
        const data = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
        const noise = this.ctx.createBufferSource();
        noise.buffer = buf;
        const noiseFilter = this.ctx.createBiquadFilter();
        noiseFilter.type = 'highpass';
        noiseFilter.frequency.value = 1000;
        const noiseGain = this.ctx.createGain();
        noiseGain.gain.setValueAtTime(velocity * 0.6, time);
        noiseGain.gain.exponentialRampToValueAtTime(0.001, time + 0.12);
        noise.connect(noiseFilter);
        noiseFilter.connect(noiseGain);
        noiseGain.connect(this.gains.snare);
        noise.start(time);
        
        // Body
        const osc = this.ctx.createOscillator();
        const bodyGain = this.ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.value = 200;
        bodyGain.gain.setValueAtTime(velocity * 0.5, time);
        bodyGain.gain.exponentialRampToValueAtTime(0.001, time + 0.08);
        osc.connect(bodyGain);
        bodyGain.connect(this.gains.snare);
        osc.start(time);
        osc.stop(time + 0.1);
    }
    
    playHiHat(time, open = false, velocity = 1.0) {
        const bufLen = open ? 0.3 : 0.05;
        const bufSize = this.ctx.sampleRate * bufLen;
        const buf = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
        const data = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
        const noise = this.ctx.createBufferSource();
        noise.buffer = buf;
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'highpass';
        filter.frequency.value = open ? 7000 : 9000;
        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(velocity * (open ? 0.25 : 0.2), time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + (open ? 0.2 : 0.04));
        noise.connect(filter);
        filter.connect(gain);
        gain.connect(this.gains.hat);
        noise.start(time);
    }
    
    playPerc(time, velocity = 1.0) {
        // Metallic percussion (cowbell-ish for phonk, click for techno)
        const osc1 = this.ctx.createOscillator();
        const osc2 = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc1.type = 'square';
        osc2.type = 'square';
        osc1.frequency.value = 587; // D5
        osc2.frequency.value = 845; // ~Ab5
        gain.gain.setValueAtTime(velocity * 0.15, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 0.1);
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.value = 700;
        filter.Q.value = 5;
        osc1.connect(filter);
        osc2.connect(filter);
        filter.connect(gain);
        gain.connect(this.gains.perc);
        osc1.start(time);
        osc2.start(time);
        osc1.stop(time + 0.12);
        osc2.stop(time + 0.12);
    }
    
    playBass(time, midi, duration = 0.2) {
        if (midi <= 0) return;
        const freq = midiToFreq(midi);
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        const filter = this.ctx.createBiquadFilter();
        
        osc.type = this.genre.bassType;
        osc.frequency.value = freq;
        filter.type = 'lowpass';
        filter.frequency.value = 800 + this.tension * 2000;
        filter.Q.value = 2 + this.genre.distortion / 20;
        
        gain.gain.setValueAtTime(0, time);
        gain.gain.linearRampToValueAtTime(0.5, time + 0.01);
        gain.gain.setValueAtTime(0.5, time + duration - 0.02);
        gain.gain.linearRampToValueAtTime(0, time + duration);
        
        osc.connect(filter);
        filter.connect(gain);
        gain.connect(this.gains.bass);
        osc.start(time);
        osc.stop(time + duration + 0.01);
        
        // Sub layer
        if (this.params.subBass > 20) {
            const sub = this.ctx.createOscillator();
            const subGain = this.ctx.createGain();
            sub.type = 'sine';
            sub.frequency.value = freq / 2;
            subGain.gain.setValueAtTime(0, time);
            subGain.gain.linearRampToValueAtTime(this.params.subBass / 200, time + 0.01);
            subGain.gain.setValueAtTime(this.params.subBass / 200, time + duration - 0.02);
            subGain.gain.linearRampToValueAtTime(0, time + duration);
            sub.connect(subGain);
            subGain.connect(this.gains.sub);
            sub.start(time);
            sub.stop(time + duration + 0.01);
        }
    }
    
    playMelody(time, midi, duration = 0.15) {
        if (midi <= 0) return;
        const freq = midiToFreq(midi);
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        
        osc.type = this.genre.leadType;
        osc.frequency.value = freq;
        
        // Slight detune for richness
        const osc2 = this.ctx.createOscillator();
        osc2.type = this.genre.leadType;
        osc2.frequency.value = freq * 1.003;
        
        const mixGain = this.ctx.createGain();
        mixGain.gain.value = 0.5;
        
        gain.gain.setValueAtTime(0, time);
        gain.gain.linearRampToValueAtTime(0.2, time + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.001, time + duration);
        
        osc.connect(mixGain);
        osc2.connect(mixGain);
        mixGain.connect(gain);
        gain.connect(this.gains.melody);
        osc.start(time);
        osc2.start(time);
        osc.stop(time + duration + 0.01);
        osc2.stop(time + duration + 0.01);
    }
    
    playPad(time, midiNotes, duration = 2.0) {
        midiNotes.forEach((midi, idx) => {
            const freq = midiToFreq(midi);
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = this.genre.padType;
            osc.frequency.value = freq;
            // Slight detune per voice
            osc.detune.value = (idx - 1) * 8;
            gain.gain.setValueAtTime(0, time);
            gain.gain.linearRampToValueAtTime(0.08, time + 0.3);
            gain.gain.setValueAtTime(0.08, time + duration - 0.5);
            gain.gain.linearRampToValueAtTime(0, time + duration);
            osc.connect(gain);
            gain.connect(this.gains.pad);
            osc.start(time);
            osc.stop(time + duration + 0.01);
        });
    }
    
    playArp(time, midi, duration = 0.08) {
        if (midi <= 0) return;
        const freq = midiToFreq(midi);
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        const filter = this.ctx.createBiquadFilter();
        
        osc.type = 'sawtooth';
        osc.frequency.value = freq;
        filter.type = 'lowpass';
        filter.frequency.value = 3000 + this.tension * 5000;
        filter.Q.value = 3;
        
        gain.gain.setValueAtTime(0.12, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + duration);
        
        osc.connect(filter);
        filter.connect(gain);
        gain.connect(this.gains.arp);
        osc.start(time);
        osc.stop(time + duration + 0.01);
    }
    
    // ─── PSYCHOACOUSTIC ─────────────────────────────────────────
    
    startBinaural() {
        if (this.binauralOscL) return;
        const merger = this.ctx.createChannelMerger(2);
        
        this.binauralOscL = this.ctx.createOscillator();
        this.binauralOscR = this.ctx.createOscillator();
        const gainL = this.ctx.createGain();
        const gainR = this.ctx.createGain();
        
        this.binauralOscL.type = 'sine';
        this.binauralOscR.type = 'sine';
        this.binauralOscL.frequency.value = 200;
        this.binauralOscR.frequency.value = 207; // 7 Hz binaural beat (theta)
        gainL.gain.value = 0.04;
        gainR.gain.value = 0.04;
        
        this.binauralOscL.connect(gainL);
        this.binauralOscR.connect(gainR);
        gainL.connect(merger, 0, 0);
        gainR.connect(merger, 0, 1);
        merger.connect(this.masterGain);
        
        this.binauralOscL.start();
        this.binauralOscR.start();
        this.binauralGain = [gainL, gainR];
    }
    
    stopBinaural() {
        if (this.binauralOscL) {
            this.binauralOscL.stop();
            this.binauralOscR.stop();
            this.binauralOscL = null;
            this.binauralOscR = null;
        }
    }
    
    startShepard() {
        // Create Shepard tone — 6 sine waves spaced by octaves
        for (let i = 0; i < 6; i++) {
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = 'sine';
            osc.frequency.value = 55 * Math.pow(2, i); // A1 through A6
            // Bell curve amplitude (loudest in middle register)
            const dist = Math.abs(i - 2.5) / 3;
            gain.gain.value = 0.015 * (1 - dist * dist);
            osc.connect(gain);
            gain.connect(this.gains.fx);
            osc.start();
            this.shepardOscs.push({ osc, gain, baseFreq: 55 * Math.pow(2, i) });
        }
    }
    
    stopShepard() {
        this.shepardOscs.forEach(s => s.osc.stop());
        this.shepardOscs = [];
    }
    
    updateShepard(time) {
        if (this.shepardOscs.length === 0) return;
        // Slowly increase all frequencies for rising illusion during builds
        const rate = this.currentSection.includes('build') ? 0.002 : 0.0005;
        this.shepardOscs.forEach((s, i) => {
            let freq = s.osc.frequency.value * (1 + rate);
            // Wrap around if too high
            if (freq > s.baseFreq * 2) {
                freq = s.baseFreq;
                // Fade out and back in when wrapping
            }
            s.osc.frequency.value = freq;
            // Update amplitude based on position in hearing range
            const logFreq = Math.log2(freq / 55);
            const center = 3.5;
            const sigma = 2.5;
            const amp = Math.exp(-0.5 * Math.pow((logFreq - center) / sigma, 2));
            s.gain.gain.value = 0.015 * amp * (this.currentSection.includes('build') ? 1.5 : 0.5);
        });
    }
    
    // ─── SECTION MANAGEMENT ─────────────────────────────────────
    
    advanceSection() {
        const transitions = this.sectionWeights[this.currentSection];
        if (!transitions) {
            this.currentSection = 'intro';
            return;
        }
        // Weighted random selection
        let total = 0;
        for (let k in transitions) total += transitions[k];
        let r = Math.random() * total;
        let cumulative = 0;
        for (let k in transitions) {
            cumulative += transitions[k];
            if (r <= cumulative) {
                this.currentSection = k;
                break;
            }
        }
        
        // Set section properties
        switch (this.currentSection) {
            case 'intro':
                this.sectionLength = pick([4, 8]);
                this.targetTension = 0.1;
                break;
            case 'build':
            case 'build2':
                this.sectionLength = pick([4, 8, 16]);
                this.targetTension = 0.8;
                break;
            case 'drop':
            case 'drop2':
                this.sectionLength = pick([8, 16]);
                this.targetTension = 1.0;
                break;
            case 'breakdown':
                this.sectionLength = pick([4, 8]);
                this.targetTension = 0.2;
                break;
            case 'outro':
                this.sectionLength = pick([4, 8]);
                this.targetTension = 0.05;
                break;
        }
        
        this.sectionBar = 0;
        
        // Regenerate patterns occasionally for variation
        if (Math.random() > 0.5) {
            this.regeneratePatterns();
        }
        
        // New melodic content each section
        this.generateMelodicContent();
        
        // Possibly change key
        if (Math.random() > 0.8) {
            this.rootKey = (this.rootKey + pick([5, 7, 2, 10])) % 12; // modulate by 4th, 5th, 2nd, or minor 3rd
            this.rootNote = 36 + this.rootKey;
            this.scale = SCALES[pick(this.genre.scales)];
            this.melodyGen = new MarkovMelody(this.scale, this.rootNote + 24);
            this.arpGen = new MarkovMelody(this.scale, this.rootNote + 12);
            this.generateMelodicContent();
        }
        
        this.updateStatus();
    }
    
    // ─── SCHEDULER ──────────────────────────────────────────────
    
    start() {
        if (!this.ctx) this.init();
        if (this.ctx.state === 'suspended') this.ctx.resume();
        
        this.playing = true;
        this.currentStep = 0;
        this.currentBar = 0;
        this.sectionBar = 0;
        this.currentSection = 'intro';
        this.tension = 0;
        this.targetTension = 0.1;
        this.nextNoteTime = this.ctx.currentTime + 0.05;
        
        this.advanceSection();
        this.scheduler();
    }
    
    stop() {
        this.playing = false;
        if (this.schedulerTimer) {
            clearTimeout(this.schedulerTimer);
            this.schedulerTimer = null;
        }
        this.stopBinaural();
        this.stopShepard();
    }
    
    scheduler() {
        if (!this.playing) return;
        
        while (this.nextNoteTime < this.ctx.currentTime + this.lookahead) {
            this.scheduleStep(this.currentStep, this.nextNoteTime);
            this.advanceStep();
        }
        
        this.schedulerTimer = setTimeout(() => this.scheduler(), this.scheduleInterval);
    }
    
    advanceStep() {
        const secondsPerBeat = 60.0 / this.bpm;
        const secondsPer16th = secondsPerBeat / 4;
        
        // Apply swing to even 16th notes
        let swingAmount = (this.params.swing / 100) * secondsPer16th * 0.5;
        if (this.genre.swing > 0) swingAmount = Math.max(swingAmount, this.genre.swing * secondsPer16th * 0.5);
        
        let stepDuration = secondsPer16th;
        if (this.currentStep % 2 === 0) {
            stepDuration += swingAmount;
        } else {
            stepDuration -= swingAmount;
        }
        stepDuration = Math.max(stepDuration, secondsPer16th * 0.3);
        
        this.nextNoteTime += stepDuration;
        this.currentStep++;
        
        if (this.currentStep >= 16) {
            this.currentStep = 0;
            this.currentBar++;
            this.sectionBar++;
            this.currentChordIdx = (this.currentChordIdx + 1) % 4;
            
            if (this.sectionBar >= this.sectionLength) {
                this.advanceSection();
            }
        }
        
        // Update tension
        this.tension = lerp(this.tension, this.targetTension, 0.02);
        
        // Perlin automation
        this.perlinTime += 0.01;
        this.automate();
        
        // Auto DJ
        if (this.autoDJ) {
            this.autoDJTimer++;
            if (this.autoDJTimer > 200 + Math.random() * 400) { // Change genre every ~30-60 seconds
                this.autoDJTimer = 0;
                const genreKeys = Object.keys(GENRES);
                let newGenre;
                do { newGenre = pick(genreKeys); } while (newGenre === this.genreKey);
                this.setGenre(newGenre);
            }
        }
    }
    
    automate() {
        // Perlin noise-driven filter modulation
        const filterMod = this.perlin.octaveNoise(this.perlinTime * 0.3, 3, 0.5);
        const baseFilter = this.genre.filterBase + this.tension * this.genre.filterRange;
        const modFilter = baseFilter + filterMod * 2000;
        if (this.filterNode) {
            this.filterNode.frequency.value = clamp(modFilter, 100, 18000);
        }
        
        // Update Shepard tones
        if (this.shepardEnabled) {
            this.updateShepard(this.perlinTime);
        }
        
        // Build section: gradually increase tension
        if (this.currentSection === 'build' || this.currentSection === 'build2') {
            const progress = this.sectionBar / this.sectionLength;
            this.targetTension = 0.3 + progress * 0.7;
        }
    }
    
    scheduleStep(step, time) {
        const section = this.currentSection;
        const barInSection = this.sectionBar;
        const complexity = this.params.complexity / 100;
        const vel = 0.7 + this.tension * 0.3;
        
        // Drums (modified by section)
        const drumsActive = section !== 'intro' || barInSection > 1;
        const kickActive = section !== 'breakdown' || step % 8 === 0;
        
        if (drumsActive && kickActive && this.kickPat[step]) {
            const kickVel = vel * (step === 0 ? 1.0 : 0.85);
            this.playKick(time, kickVel);
        }
        
        if (drumsActive && this.snarePat[step]) {
            this.playSnare(time, vel * 0.9);
        }
        
        if (drumsActive && this.hatPat[step]) {
            this.playHiHat(time, false, vel * (0.5 + Math.random() * 0.3));
        }
        
        if (drumsActive && this.hatOpenPat[step]) {
            this.playHiHat(time, true, vel * 0.6);
        }
        
        // Percussion (added with complexity)
        if (drumsActive && this.percPat[step] && complexity > 0.3) {
            this.playPerc(time, vel * 0.5);
        }
        
        // Bass
        const barIdx = this.currentChordIdx % 4;
        if (this.bassNotes[barIdx] && section !== 'intro') {
            const bassNote = this.bassNotes[barIdx][step];
            if (bassNote > 0) {
                const dur = 60 / this.bpm / 2;
                this.playBass(time, bassNote, dur);
            }
        }
        
        // Melody (drops and breakdowns mainly)
        if ((section === 'drop' || section === 'drop2' || section === 'breakdown') && complexity > 0.2) {
            if (this.melodyNotes[barIdx] && this.melodyNotes[barIdx][step] > 0) {
                const dur = 60 / this.bpm / 4 * (1 + Math.random());
                this.playMelody(time, this.melodyNotes[barIdx][step], dur);
            }
        }
        
        // Pads (breakdowns, intros, and softer sections)
        if (step === 0 && (section === 'breakdown' || section === 'intro' || section === 'build' || section === 'build2')) {
            const chordDeg = this.chordProg[barIdx];
            const chordRoot = this.rootNote + 12 + (this.scale[chordDeg % this.scale.length] || 0);
            const chordType = pick(this.genre.chordTypes);
            const padNotes = CHORDS[chordType].map(interval => chordRoot + interval);
            this.playPad(time, padNotes, 60 / this.bpm * 4);
        }
        
        // Arp (builds and drops)
        if ((section === 'build' || section === 'build2' || section === 'drop' || section === 'drop2') && complexity > 0.3) {
            if (this.arpNotes[barIdx] && this.arpNotes[barIdx][step] > 0) {
                const dur = 60 / this.bpm / 8;
                this.playArp(time, this.arpNotes[barIdx][step], dur);
            }
        }
        
        // FX: Noise riser during builds
        if ((section === 'build' || section === 'build2') && step === 0 && barInSection === this.sectionLength - 2) {
            this.playRiser(time, 60 / this.bpm * 8);
        }
        
        // FX: Impact on drop
        if ((section === 'drop' || section === 'drop2') && barInSection === 0 && step === 0) {
            this.playImpact(time);
        }
    }
    
    playRiser(time, duration) {
        const bufSize = this.ctx.sampleRate * duration;
        const buf = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
        const data = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
        const noise = this.ctx.createBufferSource();
        noise.buffer = buf;
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(500, time);
        filter.frequency.exponentialRampToValueAtTime(8000, time + duration);
        filter.Q.value = 5;
        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(0.001, time);
        gain.gain.exponentialRampToValueAtTime(0.3, time + duration);
        noise.connect(filter);
        filter.connect(gain);
        gain.connect(this.gains.fx);
        noise.start(time);
    }
    
    playImpact(time) {
        // Sub boom
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(80, time);
        osc.frequency.exponentialRampToValueAtTime(20, time + 0.8);
        gain.gain.setValueAtTime(0.8, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 1.0);
        osc.connect(gain);
        gain.connect(this.gains.fx);
        osc.start(time);
        osc.stop(time + 1.1);
        
        // Noise crash
        const bufSize = this.ctx.sampleRate * 0.5;
        const buf = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
        const data = buf.getChannelData(0);
        for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
        const noise = this.ctx.createBufferSource();
        noise.buffer = buf;
        const noiseGain = this.ctx.createGain();
        noiseGain.gain.setValueAtTime(0.4, time);
        noiseGain.gain.exponentialRampToValueAtTime(0.001, time + 0.4);
        noise.connect(noiseGain);
        noiseGain.connect(this.gains.fx);
        noise.start(time);
    }
    
    // ─── MIX LEVELS ─────────────────────────────────────────────
    
    updateMixLevels() {
        if (!this.gains.kick) return;
        this.gains.kick.gain.value = this.params.mixKick / 100;
        this.gains.snare.gain.value = this.params.mixSnare / 100;
        this.gains.hat.gain.value = this.params.mixHat / 100;
        this.gains.bass.gain.value = this.params.mixBass / 100;
        this.gains.melody.gain.value = this.params.mixMelody / 100;
        this.gains.pad.gain.value = this.params.mixPad / 100;
        this.gains.arp.gain.value = this.params.mixArp / 100;
        this.gains.fx.gain.value = this.params.mixFx / 100;
        this.gains.perc.gain.value = this.params.mixHat / 100 * 0.6;
        this.gains.sub.gain.value = this.params.mixBass / 100;
    }
    
    updateStatus() {
        const stGenre = document.getElementById('stGenre');
        const stKey = document.getElementById('stKey');
        const stSection = document.getElementById('stSection');
        const stBar = document.getElementById('stBar');
        const tensionFill = document.getElementById('tensionFill');
        
        if (stGenre) stGenre.textContent = this.genre.name;
        if (stKey) stKey.textContent = NOTE_NAMES[this.rootKey] + ' ' + (this.scale === SCALES.major ? 'Maj' : 'min');
        if (stSection) stSection.textContent = this.currentSection.toUpperCase();
        if (stBar) stBar.textContent = this.currentBar;
        if (tensionFill) tensionFill.style.width = (this.tension * 100) + '%';
    }
}

// ─── VISUALIZER ─────────────────────────────────────────────────

class Visualizer {
    constructor(canvas, analyser) {
        this.canvas = canvas;
        this.ctx2d = canvas.getContext('2d');
        this.analyser = analyser;
        this.bufferLength = analyser.frequencyBinCount;
        this.dataArray = new Uint8Array(this.bufferLength);
        this.freqArray = new Uint8Array(this.bufferLength);
        this.running = false;
        this.hue = 180;
        this.resize();
        window.addEventListener('resize', () => this.resize());
    }
    
    resize() {
        const rect = this.canvas.parentElement.getBoundingClientRect();
        this.canvas.width = this.canvas.offsetWidth * (window.devicePixelRatio || 1);
        this.canvas.height = this.canvas.offsetHeight * (window.devicePixelRatio || 1);
        this.ctx2d.scale(window.devicePixelRatio || 1, window.devicePixelRatio || 1);
        this.width = this.canvas.offsetWidth;
        this.height = this.canvas.offsetHeight;
    }
    
    start() {
        this.running = true;
        this.draw();
    }
    
    stop() {
        this.running = false;
    }
    
    draw() {
        if (!this.running) return;
        requestAnimationFrame(() => this.draw());
        
        const ctx = this.ctx2d;
        const w = this.width;
        const h = this.height;
        
        this.analyser.getByteTimeDomainData(this.dataArray);
        this.analyser.getByteFrequencyData(this.freqArray);
        
        // Dark background with fade
        ctx.fillStyle = 'rgba(10, 10, 15, 0.3)';
        ctx.fillRect(0, 0, w, h);
        
        // Frequency bars
        const barCount = 64;
        const barWidth = w / barCount;
        const step = Math.floor(this.bufferLength / barCount);
        
        for (let i = 0; i < barCount; i++) {
            const val = this.freqArray[i * step] / 255;
            const barH = val * h * 0.8;
            
            const hue = (this.hue + i * 3) % 360;
            ctx.fillStyle = `hsla(${hue}, 80%, ${40 + val * 30}%, ${0.4 + val * 0.4})`;
            ctx.fillRect(i * barWidth + 1, h - barH, barWidth - 2, barH);
            
            // Mirror reflection
            ctx.fillStyle = `hsla(${hue}, 80%, ${40 + val * 30}%, ${0.1 + val * 0.1})`;
            ctx.fillRect(i * barWidth + 1, 0, barWidth - 2, barH * 0.3);
        }
        
        // Waveform
        ctx.beginPath();
        ctx.strokeStyle = `hsla(${this.hue}, 100%, 70%, 0.7)`;
        ctx.lineWidth = 1.5;
        const sliceWidth = w / this.bufferLength;
        let x = 0;
        for (let i = 0; i < this.bufferLength; i++) {
            const v = this.dataArray[i] / 128.0;
            const y = v * h / 2;
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
            x += sliceWidth;
        }
        ctx.stroke();
        
        this.hue = (this.hue + 0.3) % 360;
    }
}

// ─── BACKGROUND ANIMATION ───────────────────────────────────────

class BgAnimation {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.particles = [];
        this.resize();
        window.addEventListener('resize', () => this.resize());
        for (let i = 0; i < 50; i++) {
            this.particles.push({
                x: Math.random() * this.w,
                y: Math.random() * this.h,
                vx: (Math.random() - 0.5) * 0.5,
                vy: (Math.random() - 0.5) * 0.5,
                size: Math.random() * 2 + 0.5,
                hue: Math.random() * 360
            });
        }
        this.animate();
    }
    
    resize() {
        this.w = window.innerWidth;
        this.h = window.innerHeight;
        this.canvas.width = this.w;
        this.canvas.height = this.h;
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        const ctx = this.ctx;
        ctx.fillStyle = 'rgba(10, 10, 15, 0.05)';
        ctx.fillRect(0, 0, this.w, this.h);
        
        this.particles.forEach(p => {
            p.x += p.vx;
            p.y += p.vy;
            if (p.x < 0 || p.x > this.w) p.vx *= -1;
            if (p.y < 0 || p.y > this.h) p.vy *= -1;
            p.hue = (p.hue + 0.2) % 360;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            ctx.fillStyle = `hsla(${p.hue}, 70%, 60%, 0.4)`;
            ctx.fill();
        });
        
        // Draw connections
        ctx.strokeStyle = 'rgba(0, 240, 255, 0.03)';
        ctx.lineWidth = 0.5;
        for (let i = 0; i < this.particles.length; i++) {
            for (let j = i + 1; j < this.particles.length; j++) {
                const dx = this.particles[i].x - this.particles[j].x;
                const dy = this.particles[i].y - this.particles[j].y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < 150) {
                    ctx.beginPath();
                    ctx.moveTo(this.particles[i].x, this.particles[i].y);
                    ctx.lineTo(this.particles[j].x, this.particles[j].y);
                    ctx.stroke();
                }
            }
        }
    }
}

// ─── UI CONTROLLER ──────────────────────────────────────────────

class UIController {
    constructor(engine) {
        this.engine = engine;
        this.visualizer = null;
        this.setupGenreGrid();
        this.setupControls();
        this.setupStatusUpdater();
        new BgAnimation(document.getElementById('bg-canvas'));
    }
    
    setupGenreGrid() {
        const grid = document.getElementById('genreGrid');
        Object.keys(GENRES).forEach(key => {
            const g = GENRES[key];
            const btn = document.createElement('button');
            btn.className = 'genre-btn';
            btn.dataset.genre = key;
            btn.innerHTML = `${g.name}<div class="bpm">${g.bpm[0]}-${g.bpm[1]} BPM</div>`;
            btn.style.borderColor = 'rgba(255,255,255,0.08)';
            btn.addEventListener('mouseenter', () => {
                if (!btn.classList.contains('active')) btn.style.borderColor = g.color;
            });
            btn.addEventListener('mouseleave', () => {
                if (!btn.classList.contains('active')) btn.style.borderColor = 'rgba(255,255,255,0.08)';
            });
            btn.addEventListener('click', () => {
                this.engine.setGenre(key);
                document.querySelectorAll('.genre-btn').forEach(b => {
                    b.classList.remove('active');
                    b.style.borderColor = 'rgba(255,255,255,0.08)';
                });
                btn.classList.add('active');
                btn.style.borderColor = g.color;
            });
            grid.appendChild(btn);
        });
    }
    
    setupControls() {
        const engine = this.engine;
        
        // Play button
        document.getElementById('playBtn').addEventListener('click', () => {
            if (!engine.playing) {
                engine.start();
                document.getElementById('playBtn').textContent = '⏸';
                document.getElementById('playBtn').classList.add('playing');
                if (!this.visualizer) {
                    this.visualizer = new Visualizer(document.getElementById('visualizer'), engine.analyser);
                }
                this.visualizer.start();
                if (engine.psychEnabled) engine.startBinaural();
                if (engine.shepardEnabled) engine.startShepard();
            } else {
                engine.stop();
                document.getElementById('playBtn').textContent = '▶';
                document.getElementById('playBtn').classList.remove('playing');
                if (this.visualizer) this.visualizer.stop();
            }
        });
        
        // Master volume
        this.bindSlider('masterVol', v => {
            engine.params.masterVol = v / 100;
            if (engine.masterGain) engine.masterGain.gain.value = v / 100;
        });
        
        // BPM
        const bpmSlider = document.getElementById('bpmSlider');
        bpmSlider.addEventListener('input', () => {
            engine.bpm = parseInt(bpmSlider.value);
            document.getElementById('bpmDisplay').textContent = engine.bpm;
        });
        
        // Synthesis controls
        this.bindSlider('filterCut', v => {
            engine.params.filterCut = v;
            if (engine.filterNode) engine.filterNode.frequency.value = v;
        }, 'filterVal');
        
        this.bindSlider('filterRes', v => {
            engine.params.filterRes = v;
            if (engine.filterNode) engine.filterNode.Q.value = v;
        }, 'resVal');
        
        this.bindSlider('distortion', v => { engine.params.distortion = v; }, 'distVal');
        this.bindSlider('subBass', v => { engine.params.subBass = v; }, 'subVal');
        
        // Effects
        this.bindSlider('reverbMix', v => {
            engine.params.reverbMix = v;
            if (engine.reverbGain) engine.reverbGain.gain.value = v / 100;
        }, 'revVal');
        
        this.bindSlider('delayMix', v => {
            engine.params.delayMix = v;
            if (engine.delayGain) engine.delayGain.gain.value = v / 100;
        }, 'delVal');
        
        this.bindSlider('swing', v => { engine.params.swing = v; }, 'swingVal');
        this.bindSlider('complexity', v => { engine.params.complexity = v; }, 'compVal');
        
        // Mix levels
        this.bindSlider('mixKick', v => { engine.params.mixKick = v; engine.updateMixLevels(); }, 'kickVal');
        this.bindSlider('mixSnare', v => { engine.params.mixSnare = v; engine.updateMixLevels(); }, 'snareVal');
        this.bindSlider('mixHat', v => { engine.params.mixHat = v; engine.updateMixLevels(); }, 'hatVal');
        this.bindSlider('mixBass', v => { engine.params.mixBass = v; engine.updateMixLevels(); }, 'bassVal');
        this.bindSlider('mixMelody', v => { engine.params.mixMelody = v; engine.updateMixLevels(); }, 'melVal');
        this.bindSlider('mixPad', v => { engine.params.mixPad = v; engine.updateMixLevels(); }, 'padVal');
        this.bindSlider('mixArp', v => { engine.params.mixArp = v; engine.updateMixLevels(); }, 'arpVal');
        this.bindSlider('mixFx', v => { engine.params.mixFx = v; engine.updateMixLevels(); }, 'fxVal');
        
        // Toggle buttons
        document.getElementById('autoDjBtn').addEventListener('click', function() {
            engine.autoDJ = !engine.autoDJ;
            this.classList.toggle('active');
        });
        
        document.getElementById('psychBtn').addEventListener('click', function() {
            engine.psychEnabled = !engine.psychEnabled;
            this.classList.toggle('active');
            if (engine.playing) {
                if (engine.psychEnabled) engine.startBinaural();
                else engine.stopBinaural();
            }
        });
        
        document.getElementById('shepardBtn').addEventListener('click', function() {
            engine.shepardEnabled = !engine.shepardEnabled;
            this.classList.toggle('active');
            if (engine.playing) {
                if (engine.shepardEnabled) engine.startShepard();
                else engine.stopShepard();
            }
        });
    }
    
    bindSlider(id, callback, displayId) {
        const slider = document.getElementById(id);
        if (!slider) return;
        slider.addEventListener('input', () => {
            const v = parseFloat(slider.value);
            callback(v);
            if (displayId) {
                const disp = document.getElementById(displayId);
                if (disp) disp.textContent = Math.round(v);
            }
        });
    }
    
    setupStatusUpdater() {
        setInterval(() => {
            if (this.engine.playing) {
                this.engine.updateStatus();
            }
        }, 200);
    }
}

// ─── INITIALIZE ─────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
    const engine = new EcstasisEngine();
    const ui = new UIController(engine);
    
    // Select house by default
    const houseBtn = document.querySelector('.genre-btn[data-genre="house"]');
    if (houseBtn) {
        houseBtn.classList.add('active');
        houseBtn.style.borderColor = GENRES.house.color;
    }
});

})();
