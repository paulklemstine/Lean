# The Star That Refuses to Disappear

## A small graph, a sharp question, and a number that should have been zero

Take a social network — people are dots, friendships are lines. Now go hunting
for a very particular little shape: one person, call them the *center*, who is
friends with two others, where exactly one of those two friendships is "present"
and the rest of the configuration is pinned down by who-knows-whom. This shape
has a name in graph theory: the **star $S_{2,1}$**. It is almost the smallest
interesting structure you can ask about, and yet it hides a surprise that took a
careful mix of construction, refutation, and curvature to pin down.

The question we tackle sounds innocent. *If I fix how dense a network is — say,
half of all possible friendships exist — how few copies of this little star can I
possibly force the network to contain?* In the language of extremal graph theory,
we want the **minimum semi-induced density** of $S_{2,1}$ at a given edge density
$\beta$. You would expect a clean formula, and indeed there is a candidate, a
single elegant curve. The twist is that the candidate is *right almost
everywhere and wrong exactly where it matters most* — and proving precisely where
and why it breaks is the heart of this story.

## The candidate curve

Here is the construction that gives the candidate. It has one knob, a number
$t$ between $0$ and $1$, and it splits the vertices into a few classes whose sizes
depend on $t$ (a "complement-split" arrangement). Turn the knob and two things
move together:

- The **edge density** traces out
$$\beta(t) = t\left(1 - \tfrac{t}{2}\right) = t - \tfrac{t^2}{2}.$$
- The **star density** traces out
$$p(t) = t^2(1 - t).$$

So if you tell me the edge density $\beta$ you want, I solve the first equation
for $t$ and read off the star density from the second. That is the candidate
profile $p_{\min}(\beta) = t^2(1-t)$, where $t$ is the unique solution of
$\beta = t(1 - t/2)$.

Two facts about $\beta(t)$ are worth stating precisely, because everything hinges
on them. First, **the edge density is capped at one half**: for every choice of
$t$ in $[0,1]$,
$$\beta(t) = t\left(1 - \tfrac{t}{2}\right) \le \tfrac{1}{2},$$
and the cap is reached exactly when the knob is turned all the way up, $\beta(1) =
1 \cdot (1 - 1/2) = 1/2$. Second, $\beta(t)$ is **strictly increasing** on
$[0,1]$, so it is a perfect one-to-one correspondence between the knob settings
$t \in [0,1]$ and the achievable densities $\beta \in [0, 1/2]$. Every target
density up to one half has exactly one knob setting that produces it — no more, no
less.

That last sentence already contains the first crack. The construction only ever
reaches edge densities up to $1/2$. So the sweeping claim "for *every* density
$\beta \in [0,1]$ the minimum is $t^2(1-t)$" cannot even be parsed for $\beta >
1/2$: there is simply no knob setting $t$ that produces such a density. Ask for
edge density $3/4$ and the construction shrugs — no $t \in [0,1]$ solves $t(1 -
t/2) = 3/4$, because the left side never climbs past $1/2$. The headline formula
is **ill-posed above one half**. The honest domain of the construction is the
lower half of the density scale, $[0, 1/2]$, and the upper half is a different
(complementary) problem entirely.

## Where the curve is beautiful

On its honest range the candidate curve is genuinely lovely. Picture $p(t) =
t^2(1-t)$ as the knob turns from $0$ to $1$. It starts at zero (an empty-ish
network has almost no stars), rises to a single rounded peak, and then comes back
down to zero. The peak sits at $t = 2/3$, and its height is
$$p\!\left(\tfrac{2}{3}\right) = \left(\tfrac{2}{3}\right)^2\left(1 - \tfrac{2}{3}\right) = \tfrac{4}{9}\cdot\tfrac{1}{3} = \tfrac{4}{27}.$$
That number, $4/27 \approx 0.148$, is a hard ceiling: no single "local density" a
vertex can have contributes more than $4/27$ to the star count. The reason is a
one-line piece of algebra that is prettier than it has any right to be. Write the
per-vertex contribution as $f(d) = d^2(1-d)$, where $d$ is the fraction of
possible neighbours a given vertex actually has. Then
$$\tfrac{4}{27} - f(d) = \tfrac{4}{27} - d^2(1-d) = \tfrac{1}{27}(3d-2)^2(\ldots) \ge 0,$$
or more plainly, the gap to $4/27$ is controlled by the perfect square $(3d -
2)^2$, which vanishes exactly at $d = 2/3$. A square is never negative; therefore
$f$ never exceeds $4/27$; therefore the peak is exactly where and how high we
said. The whole construction profile inherits this ceiling: at every honest
density, the star density stays at or below $4/27$.

## Where the curve lies

Now the wound. At the very top of the honest range, $\beta = 1/2$ (knob fully up,
$t = 1$), the formula confidently predicts
$$p_{\min}\!\left(\tfrac12\right) = 1^2 \cdot (1 - 1) = 0.$$
Zero stars. The construction claims you can have a network with half its
friendships present and essentially *no* copies of $S_{2,1}$. This is false — and
the way we know it is the most instructive part of the whole episode.

Imagine relaxing the problem. Forget that we are dealing with an actual graph;
just imagine the "local densities" $d$ of the vertices as a probability
distribution with a prescribed average (the average local density *is* the edge
density $\beta$). Could a clever distribution drive the average of $f(d) =
d^2(1-d)$ all the way to zero? Easily. Put a fraction $\beta$ of the mass at $d =
1$ and the remaining $1 - \beta$ at $d = 0$. The average local density is then
$$\beta \cdot 1 + (1-\beta)\cdot 0 = \beta,$$
exactly on target, while the average of $f$ is
$$\beta \cdot f(1) + (1-\beta)\cdot f(0) = \beta \cdot 0 + (1-\beta)\cdot 0 = 0.$$
Mean correct, star density zero, for **every** $\beta \in [0,1]$. So the
*average-density constraint alone never forces a single star to appear.* If the
world were made of free-floating probability distributions, the minimum would be
zero everywhere and there would be no story.

But the world is made of graphs, and graphs are stubborn. A distribution that
puts everyone at local density $0$ or $1$ is asking for two kinds of people:
hermits connected to no one, and universal connectors befriended by everyone. The
catch is that a single universal connector — someone adjacent to all $n-1$ others
— single-handedly raises *everybody else's* local density, because everyone is now
adjacent to at least that one person. You cannot have hermits and universal
connectors coexist at intermediate density; the universal vertices drag the
hermits' degrees up off the floor. The clean two-point distribution is a
mathematical fiction that **no actual graph can realize** at density $1/2$. This
is the *realizability gap*: the abstract optimum (zero) is unreachable, and the
true minimum is pushed strictly above it.

So the formula's prediction of zero at $\beta = 1/2$ is not a small numerical
slip; it is the signature of a deep phenomenon. The positivity of the true
minimum at intermediate density does not come from the averaging constraint at all
— that allows zero. It comes *entirely* from the geometry of which degree patterns
real graphs can and cannot exhibit. The believed correct value is $p_{\min}(1/2)
= 1/12$, attained in the limit by a "threshold" network in which two people are
friends precisely when their positions on a line add up to more than a fixed
cutoff. The headline curve, exact in spirit across most of its range, snaps
precisely at the top because that is where realizability bites hardest.

## A bridge to another corner of the catalog

There is a pleasing coda. The number $1/2$ — the construction's edge-density
ceiling — turns out to be a meeting point with a completely different family of
results about *cycles*. For each cycle length $\ell$, there is a classical
"Nash–Williams style" threshold
$$\delta_{C_\ell} = \frac{\ell}{2\ell - 2},$$
which governs when a graph can be decomposed into cycles of that length. As $\ell$
grows these thresholds *decrease* toward $1/2$ but never reach it:
$\delta_{C_3} = 3/4$, $\delta_{C_4} = 2/3$, $\delta_{C_5} = 5/8$, and so on, each
strictly bigger than $1/2$. Our star construction approaches $1/2$ from *below*
(reaching it exactly at $t = 1$); the cycle thresholds approach $1/2$ from
*above* (never reaching it). They press in on the same value from opposite sides.
Concretely, every density the star construction can produce stays strictly under
every cycle threshold, and in particular the construction's ceiling sits strictly
below the headline cycle value:
$$\beta(1) = \tfrac12 \;<\; \tfrac58 = \delta_{C_5}.$$
The same humble number $1/2$ is a ceiling for one problem and a floor for
another — a quiet structural rhyme between two corners of extremal graph theory.

## The moral

The little star $S_{2,1}$ teaches a lesson that resonates far beyond it. We had a
clean formula and an elegant construction, and the temptation was to declare
victory across the board. Careful accounting revealed three sharper truths: the
formula is **only defined** on half the density range; on that range it is a
genuine, square-certified bump capped at $4/27$; and at the very boundary it
**lies**, predicting zero where reality insists on something positive — not because
of any constraint we wrote down, but because graphs cannot be any distribution
they please. The gap between what averages allow and what graphs realize is where
the real mathematics lives. The star, it turns out, refuses to disappear.
