# 💎 Hobbyist Project 6: Nonlinear Frequency Mixing — New Colors from Old

**Difficulty:** ★★★☆☆ (Intermediate)  
**Cost:** $50–150  
**Time:** 3–6 hours  
**Safety Level:** Moderate (laser diodes require eye protection)

---

## What You'll Build

Using two cheap laser diode modules and a nonlinear crystal, you'll generate coherent light at a **wavelength that neither laser can produce on its own**. This is frequency mixing — one of the most powerful techniques in modern optics, made accessible for the home experimenter.

---

## Experiments

### Experiment A: Second Harmonic Generation (Frequency Doubling)

**Concept:** Send a single laser beam through a nonlinear crystal. Out comes light at half the wavelength (double the frequency).

**Example:** 1064 nm infrared → 532 nm green (this is how green laser pointers work internally!)

**Materials:**
- Infrared laser diode (808 nm or 1064 nm module), ~$5–10
- KTP crystal (potassium titanyl phosphate) — available from surplus, ~$15–30
- Collimating lens (salvaged from DVD drive, or bought)
- IR-blocking filter (to see only the frequency-doubled light)
- IR viewing card or smartphone camera (to align the IR beam)
- Laser safety glasses for appropriate wavelength

**Procedure:**
1. Collimate the IR laser diode beam
2. Pass through the KTP crystal
3. Rotate the crystal to find the **phase-matching angle** — the orientation where the frequency-doubled light is brightest
4. Use an IR-blocking filter to observe only the visible output
5. 808 nm → faint 404 nm (violet/UV) output
6. The conversion efficiency will be low (~0.01% with unfocused CW diodes) but detectable

### Experiment B: Sum Frequency Generation

**Concept:** Two beams at different frequencies combine in a crystal to produce light at the sum of their frequencies.

**Example:** 650 nm (red) + 808 nm (IR) → ~361 nm (UV)

**Materials:**
- Red laser diode (650 nm), ~$5
- IR laser diode (808 nm), ~$5
- BBO crystal or home-grown KDP crystal, $10–40
- Beam-combining optics (beam splitter or simple geometry)

**Procedure:**
1. Collimate both beams
2. Cross them inside the nonlinear crystal at the appropriate angle
3. Look for UV output using fluorescent paper (it will glow where UV hits)
4. Adjust crystal angle and beam overlap to maximize signal

### Experiment C: Home-Grown KDP Crystal

**Materials:**
- KDP powder (potassium dihydrogen phosphate), ~$10 for 500g
- Warm distilled water
- Clean glass jar
- String/seed crystal
- Patience (1–3 weeks for a good crystal)

**Growing Process:**
1. Dissolve KDP in warm water until saturated (~33g per 100mL at 25°C)
2. Filter the solution through a coffee filter
3. Pour into a clean glass jar
4. Hang a seed crystal (a small chip of KDP or a rough string) in the solution
5. Cover with paper towel (allows slow evaporation)
6. Store in a vibration-free location at stable temperature
7. Over 1–3 weeks, a crystal will grow on the seed
8. Harvest when it reaches 1–2 cm
9. Polish faces with fine sandpaper (1000+ grit)

**Using your crystal:**
- KDP has nonlinear optical properties — it can frequency-double light
- Pass a focused laser beam through your crystal
- At the right angle, you'll generate (very faint) second harmonic light
- This is essentially how scientific nonlinear optics was born!

---

## The Physics

### Why Does This Work?

In a normal (linear) material, the polarization P is proportional to the electric field E:

P = ε₀ χ⁽¹⁾ E

In a nonlinear crystal, there's an additional term:

P = ε₀ (χ⁽¹⁾ E + χ⁽²⁾ E² + ...)

The χ⁽²⁾ E² term means that two waves at frequencies ω₁ and ω₂ create a polarization oscillating at ω₁+ω₂ (sum frequency) and ω₁-ω₂ (difference frequency). This oscillating polarization radiates a new electromagnetic wave at the new frequency.

### Phase Matching

For efficient conversion, the generated wave must travel at the same speed as the driving polarization wave. This "phase matching" condition depends on the crystal angle:

n(ω₃) ω₃ = n(ω₁) ω₁ + n(ω₂) ω₂

By rotating the crystal, you change the effective refractive indices (because nonlinear crystals are birefringent) until this condition is satisfied.

Finding the phase-matching angle is the key experimental challenge and the most satisfying "aha!" moment when you see the new color appear.

---

## Expected Results

With CW laser diodes (typically 5–50 mW) and small crystals:
- **SHG efficiency:** ~0.001–0.01% (microwatts of output)
- **SFG efficiency:** ~0.0001–0.001% (sub-microwatt)

This is too dim to see directly, but detectable with:
- Fluorescent paper/card (UV output makes it glow)
- Smartphone camera (many phone cameras can see near-UV)
- Photodiode + amplifier circuit

With pulsed laser sources (e.g., a Q-switched pointer, which some green lasers use internally):
- **SHG efficiency:** ~1–10% (easily visible!)
- The green laser pointer itself is an SHG demonstration: it frequency-doubles 1064 nm to 532 nm internally

---

## Safety

**CRITICAL: Laser eye safety applies to ALL experiments in this project.**

- Never look directly into any laser beam or its reflections
- Wear laser safety glasses rated for your laser wavelength(s)
- Be aware of UV output — UV can damage eyes and skin without being visible
- Keep beam paths below eye level
- Remove reflective jewelry
- Post warning signs when lasers are operating
- Never aim lasers at people, animals, or vehicles

---

## Going Further

- **OPO (Optical Parametric Oscillator):** With a pulsed pump laser and a nonlinear crystal inside a cavity, you can generate tunable coherent light — any wavelength from UV to IR
- **Cascaded SHG:** Frequency-double twice (1064→532→266 nm) for deep UV
- **Difference Frequency Generation:** Create coherent infrared/THz radiation
- **Entangled Photon Generation:** Spontaneous parametric down-conversion in nonlinear crystals produces quantum-entangled photon pairs — the basis of quantum optics experiments!
