# The Slope That Wasn't a Cliff

*How exact arithmetic settled an argument about a number that was falling*

---

## A number that falls

Here is a small drama with big consequences.

Somebody is studying a measurement — call it a *dial* — that assigns a number to each of a large collection of binary keys. The dial has two knobs. One knob is the **bit length** $b$: how wide the keys are, $32$ bits, $54$ bits, $64$ bits. The other is a **cap** $u$: a deliberate blurring, an instruction to the dial to stop distinguishing details finer than a certain resolution.

For each setting of the two knobs, one records a single number: how well the dial's ranking agrees with the ranking of some quantity of interest. That agreement is measured on a scale where $1$ means perfect and $0$ means nothing. Sweeping a full grid of four bit lengths by three caps produces twelve numbers, and they tell a clean story: the agreement is $0.79$ at the friendliest corner, $0.53$ at the harshest, and it slides downhill as either knob is turned. Nothing in between jumps by more than $0.09$.

Now the argument starts. What does that slide *mean*?

There are exactly three ways to read it, and they could not be more different in their consequences.

**Reading one: a genuine, gradual decline.** The dial really does lose touch with its target as the knobs turn, and it loses touch steadily. You can trade one knob against another; nothing catastrophic lurks at any particular setting.

**Reading two: the dial hit its own ceiling.** Perhaps the dial is not losing touch at all. Perhaps at certain settings it simply becomes *incapable* of scoring higher — it runs out of resolution, the way a bathroom scale that reads in whole kilograms cannot report a gain of $200$ grams no matter how real that gain is. If so, the numbers describe the instrument, not the world, and the entire experiment is measuring its own limitations.

**Reading three: a bookkeeping accident.** The dial requires one arbitrary decision. Among the keys is the number zero, and zero is a peculiar case: the dial asks "how many trailing zero bits does this number have?", and zero has, in a certain sense, all of them. So somebody must decide where zero goes. What if the whole downward slide is an artifact of that one convention, applied to that one key?

Readings two and three are the dangerous ones. If either holds, the finding evaporates. This is the story of how both were eliminated — not by argument, not by simulation, but by computing the relevant quantities exactly and finding them too small to matter by factors of ten thousand and a billion respectively.

---

## The dial, precisely

The keys are the integers from $0$ to $2^b - 1$, so there are $N = 2^b$ of them. For a nonzero key $x$, write $v_2(x)$ for the number of zero bits at the end of its binary expansion: $v_2(12) = 2$, because $12 = 1100_2$. The dial with cap $u$ is
$$T_u(x) = \min\bigl(v_2(x),\, u\bigr).$$
It reports the trailing-zero count, but refuses to count past $u$.

This is a spectacularly coarse instrument. Exactly half of all keys are odd, so half of them get the value $0$. A quarter get $1$. An eighth get $2$. And everything with at least $u$ trailing zeros — a fraction $2^{-u}$ of the keys — gets lumped together at the top.

Those lumps matter enormously, and they are the key to the whole story. A ranking with ties can never agree perfectly with anything. If half your data points are declared equal, you have thrown away the information needed to order them, permanently. There is a **ceiling**: a largest agreement score the dial could achieve even against an ideally cooperative target.

This ceiling is not a vague notion. It is a specific number determined entirely by the sizes of the tie groups. If the groups have sizes $m_1, m_2, \dots, m_k$ summing to $N$, the ceiling on the squared agreement is
$$\rho^2 \;=\; 1 \;-\; \frac{\sum_i \bigl(m_i^3 - m_i\bigr)}{N^3 - N}.$$
Big groups hurt cubically. That is the whole of the classical theory of ties, and it is enough.

---

## The ceiling, computed exactly

For the trailing-zero dial the group sizes are known perfectly: $2^{b-1}$ keys with no trailing zeros, $2^{b-2}$ with one, and so on down to two final groups of $2^{b-u}$ each. Plug those into the formula, sum the geometric series, and something clean falls out.

**The Product Law for the Ceiling.** For $1 \le u \le b$, the ceiling on the squared agreement is
$$\rho^2(b, u) \;=\; \underbrace{\frac{6}{7}\Bigl(1 - 8^{-u}\Bigr)}_{\text{the cap factor}} \;\times\; \underbrace{\Bigl(1 + \frac{1}{4^{b} - 1}\Bigr)}_{\text{the bit factor}}.$$

Stare at this for a moment, because three separate objections die in it.

**First: the two knobs never interact.** The ceiling is a *product* of a function of $u$ alone and a function of $b$ alone. In matrix language the ceiling grid has rank one, which means every $2\times 2$ block of it satisfies
$$\rho^2(b,u)\,\rho^2(b',u') = \rho^2(b,u')\,\rho^2(b',u).$$
No single cell can misbehave. There is no room, anywhere in the surface, for a private threshold at some particular combination of settings. A "threshold effect at bit length $54$ with cap $10$" is not unlikely here — it is arithmetically impossible.

**Second: the ceiling barely moves.** The cap factor climbs toward $6/7 \approx 0.857$ and gets there fast; by $u = 8$ it is within $10^{-7}$ of its limit. The bit factor descends toward $1$ and gets there faster; by $b = 32$ it is within $10^{-7}$ of $1$. Multiply the windows: across the *entire* recorded grid, every ceiling value lies within $10^{-6}$ of $6/7$, and any two of them differ by less than
$$10^{-5}.$$
The observed slide was $0.26$. The ceiling's total possible wobble is smaller by a factor of more than ten thousand.

**Third — and this is the beautiful part — the ceiling moves the *wrong way*.** Turn the cap knob up by one notch and the ceiling changes by exactly
$$\rho^2(b, u+1) - \rho^2(b,u) \;=\; \frac{3}{4}\,8^{-u}\Bigl(1 + \frac{1}{4^b-1}\Bigr) \;>\; 0.$$
It goes *up*. Raising the cap makes the dial finer, splits the top lump into smaller lumps, and strictly increases what the dial is capable of. Meanwhile the recorded agreement goes *down*.

So along the cap knob, the observed decline is not merely "not explained by the ceiling" — it is happening *against* a rising ceiling. Reading two is not just improbable. It has the wrong sign.

---

## Where the decline actually lives

If the capacity is constant and the score falls, then the *fraction of capacity being used* must fall. Write the observed squared score as
$$s^2 = a \cdot \rho^2,$$
where $a$ is the **attenuation**: the share of the available room that the real-world coupling actually fills. Since $\rho^2$ is pinned at $6/7$ to five decimal places everywhere in the grid, the two corners tell us
$$a_{\text{top}} \approx \frac{0.79^2}{6/7} \approx 0.728, \qquad a_{\text{bottom}} \approx \frac{0.53^2}{6/7} \approx 0.328.$$

**The Attenuation Theorem.** Between the recorded corners, the attenuation factor must drop by more than $0.4$.

The instrument's capacity holds constant to within a hundred-thousandth while the fraction of it in use collapses from about three-quarters to about a third. Whatever the sweep is detecting, it is a property of the relationship being measured — not of the arithmetic doing the measuring.

---

## The one-key question

That leaves reading three: the bookkeeping accident. Could shuffling the boundary key have caused all this?

The answer is exact and it is derived from a pretty identity. Moving one key from a tie group of size $m+1$ into a tie group of size $m'$ changes the tie penalty in the ceiling formula by exactly
$$3\bigl((m')^2 + m'\bigr) - 3\bigl(m^2 + m\bigr).$$
You pay $3(m^2+m)$ to leave a group and collect $3((m')^2+m')$ to join one. The change is **quadratic** in group size — while the denominator in the ceiling formula, $N^3 - N$, is **cubic** in the sample size. In a race between $N^2$ and $N^3$, there is no contest.

Making this precise requires one structural fact: the trailing-zero dial's tie groups are *balanced*, meaning no group holds more than half the keys. (The largest is exactly half: the odd numbers.) Under balance:

**The Convention Stability Theorem.** Moving a single key between two tie groups of a balanced profile changes the ceiling by less than $4/N$.

At $b = 32$ bits, $N$ is over four billion, and $4/N$ is about $9.3 \times 10^{-10}$. At $64$ bits it is unimaginably smaller.

**Consequence.** At any recorded bit length, *any* one-key convention change moves the ceiling by less than
$$10^{-9},$$
eight orders of magnitude below the observed $0.26$. You would need to reassign on the order of a hundred million keys before the ceiling twitched at the recorded scale. Reading three is dead.

---

## What "gradual" actually means

With the two rival explanations eliminated, one job remains: to say precisely, and provably, what "gradual" means — because the word usually means nothing at all.

Here is the machinery. Take any grid of numbers indexed by two knobs. A **notch** is the change from one cell to an adjacent one. To get from the top-left corner of a $4 \times 3$ grid to the bottom-right, walk a staircase: three steps along one knob, then two along the other, five notches in all. The first observation is an identity so simple it looks like nothing:

**The Staircase Identity.** The sum of the notches along the staircase equals exactly the difference between the two corners.

It looks like nothing, and it is everything, because it converts a global claim into a finite list of local ones. In the recorded case the five notches sum to exactly $0.26$.

Now the real theorem.

**The Spreading Law.** If every notch is non-negative and no notch exceeds $\varepsilon$, then at least $R/\varepsilon$ notches must be strictly positive, where $R$ is the total decline.

That is a pigeonhole argument, and it is what "gradual, not a cliff" actually means. If the total fall is $0.26$ and no single step falls more than $0.09$, then at least $0.26/0.09 = 2.89$, hence at least **three**, of the five steps are doing real work. And no single step can carry the whole thing, since $0.09 < 0.26$.

Two guardrails keep this honest.

*The bound is achieved.* Consider the perfectly gradual grid that starts at $0.79$ and loses exactly $0.052$ at every notch. It hits both recorded corners, it is monotone, it respects the $0.09$ bound, and it has exactly five active notches — exactly $R/\varepsilon$ rounded appropriately. So the Spreading Law cannot be improved, and the recorded pattern is genuinely achievable.

*Cliffs really exist.* Consider instead the grid that sits at $0.79$ at the corner and $0.53$ at every other cell. Same corners, same total decline of $0.26$ — but its very first notch is the entire $0.26$. This is a cliff, and it violates the recorded per-notch bound of $0.09$, and nothing else. So the gradualness verdict is not a formality that any monotone grid satisfies. It is a real constraint, and the reported per-notch bound is precisely the thing that rules the cliff out.

There is even a version for skeptics who don't trust the model. If your data is within $\delta$ of some grid whose notches are all at most $\varepsilon$, then your data's notches are all at most $\varepsilon + 2\delta$. **Approximate agreement with a gradual model already forbids cliffs.** You never have to claim the model is exactly right.

---

## The floor that isn't a floor

One more piece of folklore fell in this analysis.

An earlier study reported a "practical floor" near bit length $54$ — the setting where the dial stops being useful. The phrase conjures an edge: usable on this side, worthless on that. The staircase machinery says otherwise, and quantitatively.

**The Transition-Width Law.** If no notch of a trace drops more than $d$, then crossing a band of half-width $\eta$ around any floor takes at least $2\eta/d$ notches.

The proof is the Staircase Identity plus arithmetic: the notches between the two ends of the band must sum to at least $2\eta$, and each is at most $d$. With the recorded $d = 0.09$ and a modest band of $\pm 0.05$, the crossing needs at least **two** notches. There is no single bit length at which the dial dies.

And under a mild smoothness assumption — that each notch retains at least $7/8$ of the current value — one gets more: since $(7/8)^2 \times 0.79 = 0.605 > 0.53$, the dial *cannot* fall from the recorded top to the recorded bottom in two steps. It needs three. Better still, a dial that retains a fraction $r$ per notch can never plunge through a floor $\tau$: the first value below the floor is still at least $r\tau$, and the step on which the crossing happens moves the value by at most $(1-r)$ of it. Falling off this edge is like walking down a ramp and being told you have crossed a line painted on it.

---

## Why the shape of the argument matters

Step back and notice the structure, because it generalises well beyond binary keys.

The measurement was decomposed into two factors: **capacity**, the most the instrument could possibly report, and **coupling**, the fraction of that capacity the world actually delivers. Capacity here was not estimated or simulated. It was computed in closed form, because it depends only on the combinatorics of the instrument, which are perfectly known. Once capacity was pinned to $6/7$ across the whole experiment — with a *rising* trend along the very knob where the observation fell — the entire observed effect was forced into the coupling term, where it belongs.

Equally important is what the analysis *refused* to do. The ten interior cells of the grid were never used, or invented. Only four reported facts entered: the two corner values, the fact that the numbers decline in both directions, and the per-notch bound of $0.09$. Every conclusion is therefore a statement about *any* dataset with that summary. Re-run the experiment with different randomness and the conclusions survive unchanged, so long as the summary does. That is a much stronger position than fitting a curve to twelve numbers.

There is a reporting lesson in this. A study that publishes corners, monotonicity, and a per-notch bound has published enough for a reader to certify the *shape* of its result — gradual or cliff — without seeing the interior data at all.

---

## The verdict

The number was falling, and now we know why, and how.

It falls **gradually**: at least three of the five steps carry real weight, none of them carries more than a third of the total, and the bound is provably tight.

It does **not** fall because the instrument ran out of room. The instrument's room is $\frac{6}{7}(1 - 8^{-u})(1 + \frac{1}{4^b-1})$, it is constant to within $10^{-5}$ across the whole experiment, and it moves *upward* along the knob where the observation moves down.

It does **not** fall because of a convention about a single peculiar key. That convention is worth less than $10^{-9}$ — a billionth — against an effect of $0.26$.

And there is no cliff at the far end, no bit length at which the dial suddenly dies. The reported floor is a transition of provably positive width, at least two notches wide and probably three.

What remains is the interesting thing: a real, substantial, steady erosion of the relationship between the dial and its target, worth more than $0.4$ of attenuation, spread smoothly across the parameter space. Not an artifact. Not an edge. A slope.
