# 🧬 Hobbyist Project 4: Biolaser (Fluorescein Micro-Laser)

**Difficulty:** ★★★☆☆ (Intermediate)  
**Cost:** $30–80  
**Time:** 2–4 hours  
**Safety Level:** Low (non-toxic materials, but UV LED requires eye protection)

---

## What You'll Build

A micro-laser using concentrated fluorescein dye (a GFP analog) as the gain medium, pumped by a blue/violet LED. The dye solution forms whispering gallery mode resonators as microdroplets, or lases in a simple mirror cavity.

---

## Why Fluorescein?

Green Fluorescent Protein (GFP) has been demonstrated to lase, but pure GFP is expensive. Fluorescein is a cheap, safe, bright fluorescent dye with similar spectral properties:

| Property | GFP | Fluorescein |
|----------|-----|-------------|
| Absorption peak | 475 nm | 490 nm |
| Emission peak | 509 nm | 520 nm |
| Quantum yield | 0.79 | 0.93 |
| Cross-section | 2×10⁻¹⁶ cm² | 3×10⁻¹⁶ cm² |
| Cost per experiment | ~$30 | ~$3 |
| Toxicity | Non-toxic | Non-toxic (used in eye exams) |

Fluorescein actually has *better* laser properties than GFP!

---

## Bill of Materials

| Item | Source | Est. Cost |
|------|--------|-----------|
| Fluorescein sodium (50g) | Amazon / auto parts store (UV leak detector) | $5–10 |
| 405 nm or 450 nm LED module | Amazon / electronics store | $5–10 |
| Small concave mirrors or flat mirrors (2) | Amazon / surplus optics | $10–25 |
| Glass capillary tubes or microscope slides | Amazon | $5 |
| Glycerol (to increase viscosity for droplets) | Pharmacy | $3 |
| Syringe with fine needle (for droplets) | Pharmacy | $2 |
| UV/blue-blocking safety glasses | Amazon | $5–10 |
| 3V coin cell battery or USB power for LED | Electronics store | $2 |

---

## Method A: Capillary Cavity Laser

### Step 1: Prepare Concentrated Dye Solution
1. Dissolve fluorescein sodium in water to make a **saturated** solution (~50 mg/mL)
2. The solution should be extremely bright yellow-green
3. When illuminated with UV/blue light, it should glow vivid green
4. For best results, use a 50/50 water/glycerol mix (glycerol increases viscosity and refractive index)

### Step 2: Set Up the Cavity
1. Position two small flat mirrors parallel to each other, ~5–10 mm apart
2. Use small clamps, clips, or modeling clay to hold them in position
3. One mirror should be as reflective as possible (>99% — a quality cosmetic mirror works)
4. The other should be slightly less reflective (95–99%) — this is the output coupler
5. Place a glass capillary tube (inner diameter 0.5–1 mm) between the mirrors, perpendicular to the mirror faces

### Step 3: Fill the Cavity
1. Draw concentrated fluorescein solution into the capillary using capillary action or a syringe
2. Seal the ends with wax or tape to prevent evaporation

### Step 4: Pump and Observe
1. Position the LED module to illuminate the capillary from the side
2. Aim for maximum fluorescence excitation
3. In a dark room, observe light emerging from the output coupler mirror
4. Vary the pump intensity by adjusting LED-to-capillary distance

### What to Look For:
- Below threshold: diffuse green glow through the output mirror
- At threshold: bright, more directional green spot
- Above threshold: intense, potentially spectrally narrow output

---

## Method B: Whispering Gallery Mode Droplet Laser

This is more elegant and closer to published biolaser experiments.

### How It Works
A tiny droplet of concentrated dye solution acts as both the gain medium AND the optical cavity. Light circulates around the inside of the droplet by total internal reflection — these are "whispering gallery modes" (named after the whispering gallery in St. Paul's Cathedral, where sounds travel around the dome).

### Step 1: Prepare Viscous Dye Solution
1. Mix fluorescein sodium in glycerol (50/50 glycerol/water with 50 mg/mL fluorescein)
2. The glycerol increases viscosity (droplets hold their shape) and refractive index (better total internal reflection)

### Step 2: Create Microdroplets
1. Use a fine syringe needle to place tiny droplets (~0.5–2 mm diameter) onto a mirror surface or glass slide
2. Alternatively, dip a thin wire into the solution and let a small drop form
3. The droplet should be nearly spherical due to surface tension

### Step 3: Pump the Droplet
1. Illuminate the droplet from above or the side with the blue/violet LED
2. The LED should be close enough for intense illumination
3. Focus the LED with a small lens if possible (magnifying glass works)

### Step 4: Observe
1. Look at the droplet from the side (perpendicular to pump beam)
2. Below threshold: uniform green fluorescence
3. At threshold: bright ring at the droplet equator (light circulating inside the sphere)
4. Above threshold: sharp bright spots where WGM light escapes

---

## Method C: Ball Lens Resonator (Easiest Lasing)

### Concept
A small glass ball (ball lens) sitting in a pool of dye acts as a whispering gallery resonator. The glass ball has a higher refractive index than the dye solution, confining light to circulate inside. The dye coating provides gain.

### Materials
- Small glass beads or ball bearings (1–5 mm diameter)
- Concentrated fluorescein solution
- Blue LED

### Procedure
1. Dip a glass bead in concentrated dye solution
2. Place the coated bead on a mirror
3. Illuminate with blue LED from above
4. Observe the edges of the bead for bright emission spots
5. These spots indicate WGM resonance with gain

---

## Advanced: Building a Spectrometer to Confirm Lasing

To definitively confirm lasing, you need to observe spectral narrowing. A simple spectrometer:

1. **Slit:** Razor blade edges on a cardboard tube (~0.2 mm gap)
2. **Grating:** A piece of writable CD or DVD
3. **Detector:** Smartphone camera aimed at the diffracted spectrum
4. **Calibration:** Use known light sources (sodium lamp = 589 nm, green laser = 532 nm)

Compare the spectrum of:
- Plain fluorescein fluorescence (broad, ~40 nm wide)
- Fluorescein in cavity under strong pumping (should narrow to ~1–5 nm if lasing)

---

## Biological Variations (For the Adventurous)

### Using Actual GFP
- Recombinant GFP is available from Abcam, Sigma-Aldrich, or BioLegend (~$30–50 for a small vial)
- Dissolve in phosphate buffer at ~1 mg/mL
- Use in capillary cavity or droplet experiments identically to fluorescein
- The emission will be at 509 nm instead of 520 nm

### Bioluminescent Pump (Dream Experiment)
- Culture bioluminescent bacteria (Vibrio fischeri kits available online for ~$15)
- Grow to high density in nutrient broth
- Mix dense bacterial culture with concentrated fluorescein
- Place in capillary cavity
- Wait for the bacteria to glow (takes 12–24 hours to reach full brightness)
- Observe whether the bacterial bioluminescence pumps the fluorescein enough for any amplification

**Realistic expectation:** The bacterial light will be far too dim for lasing. But it's a beautiful experiment anyway — living organisms creating fluorescence in an optical cavity.

---

## Safety

- **Fluorescein:** FDA-approved for use in human eyes. Non-toxic. But it stains *everything* bright yellow-green. Wear old clothes.
- **UV/blue LEDs:** Can damage eyes with extended direct viewing. Wear UV-blocking glasses.
- **Glycerol:** Food-safe, non-toxic
- **GFP:** Non-toxic, non-allergenic
- **Bacteria (V. fischeri):** Biosafety Level 1 (safe for home use), but practice basic hygiene

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't see fluorescence | Use a stronger pump LED, or work in darker room |
| Droplets collapse | Add more glycerol for viscosity |
| No ring pattern in droplets | Droplet may be too large or flat — need nearly spherical |
| Can't align mirrors | Use kinematic mirror mounts (3D printable designs available online) |
| Fluorescein bleaches | Prepare fresh solution, reduce pump intensity |
