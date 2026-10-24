# The Curve That Could Not Bend: Why a Fading Signal Refuses Every Simple Story

*A correlation that fades with problem size, a hopeful model that turned out to be a theorem, and the surprising reason the theorem says nothing about the data.*

---

## A ladder of measurements

Imagine you are measuring how strongly two quantities agree as a problem gets harder. Each "rung" of your experiment is a problem size, measured in bits: 96, 100, 104, 108, 112, 116, 120. At each rung you record a correlation $\rho$, a number between $-1$ and $1$. A value near $1$ means near-perfect agreement. A value near $0$ means none.

At small sizes the correlation is healthy. As the size grows it fades. By the 108-bit rung it reads $\rho_{108} = 0.488$, well under a threshold of $0.55$ that we will call **the band**. Above that threshold the signal counts as clearly present, and you would like to know whether it can ever come back. Has the signal left the band for good, or could it climb back in at 124 or 132 bits?

This sounds like a question for more data. It turns out to be a question about **shape**. The answer depends on which smooth stories the seven measured numbers are allowed to tell, and the honest answer is a surprise: *none of the simple ones.*

## The first story: "it only goes down"

The most natural model is monotone fading. Each rung is no higher than the one before:

$$\rho_{n+1} \le \rho_n .$$

If this held from 108 bits on, nothing more would need saying. Every later reading would sit at or below $0.488$, and re-entry into the band would be impossible.

The data killed this model. Between 112 and 116 bits the correlation goes **up**, to about $0.4847$, before falling again at 120. One upward tick is enough to refute "it only goes down". A single counterexample beats any amount of plausibility.

## The second story: measure the angle, not the number

When one model fails, the next move is often to change coordinates. A correlation is secretly an angle. If you think of two signals as vectors, their correlation is the cosine of the angle between them:

$$\rho = \cos\theta, \qquad \theta = \arccos\rho \in [0,\pi].$$

Perfect agreement is $\theta = 0$. No correlation is $\theta = \pi/2$, a right angle. In this picture the band $\rho \ge 0.55$ is a **spherical cap**: the set of directions within an angle $\arccos 0.55 \approx 0.988$ radians (about $56.6^\circ$) of a reference direction. "Leaving the band" means the angle has opened past that cap. "Re-entry" means it closes back inside.

The angle coordinate suggested a gentler model than monotonicity. It is a **curvature** model. Perhaps the angle does not have to grow at every step. Perhaps it only has to *decelerate*, opening more and more slowly, the way a ball rolling up a hill slows down. In discrete form, angular deceleration says that the second difference is never positive:

$$\theta_{n+2} - 2\theta_{n+1} + \theta_n \le 0 .$$

This is the discrete version of "concave": each step is no bigger than the one before. The hope was that this condition is weaker than monotone fading, flexible enough to fit the rebound at 116, yet strong enough to keep the signal out of the band. The precise conjecture was:

> **Angular deceleration conjecture.** If $\theta_n = \arccos\rho_n$ satisfies $\theta_{n+2} - 2\theta_{n+1} + \theta_n \le 0$ for all $n$ from the 108-bit rung onward, then $\theta_n$ converges, its limit is at least $\arccos 0.488$, and therefore $\rho_n < 0.55$ at every later rung.

## Twist one: the conjecture is true

The conjecture is a theorem, and its proof rests on a short, appealing fact about concave sequences.

> **Lemma (a bounded concave sequence never steps down).** Let $s_n$ be a sequence that is concave from some index $N$ on and bounded below by some number $B$. Then $s_n \le s_{n+1}$ for every $n \ge N$.

Here is why. Concavity means the steps $s_{n+1} - s_n$ never get larger. Suppose that at some moment the sequence takes a downward step of size $\delta > 0$. Every later step is then at most $-\delta$, so after $k$ more steps

$$s_{n+k} \le s_n - k\delta .$$

That line heads to $-\infty$. Once $k$ is larger than $(s_n - B)/\delta$, the sequence has fallen below its own floor $B$, which is a contradiction. So a concave sequence with a floor can never go down. **One downward step, however tiny, is fatal.** A step of $0.001$ radians from a height of $1.2$ forces a fall below zero within about $1200$ steps.

Angles have a floor ($\theta \ge 0$) and a ceiling ($\theta \le \pi$). So a concave angle sequence is nondecreasing and bounded, and a classical theorem says such a sequence converges. Its limit is at least its value at 108 bits, which is $\arccos 0.488$. Since arccos is decreasing, an angle at least $\arccos 0.488$ means a correlation at most $0.488$. That is safely below $0.55$. The proof even works without assuming $\rho$ stays in $[-1, 1]$. Conjecture proved.

## Twist two: the theorem is empty

Look again at the lemma. Under angular concavity, the angle **never decreases** from 108 bits on. Since cosine is decreasing on $[0,\pi]$, a nondecreasing angle is exactly the same thing as a nonincreasing correlation:

> **Collapse theorem.** For any sequence of genuine correlations, angular concavity from some index on implies that $\rho$ is nonincreasing from that index on.

So the "gentler" curvature model is not gentler. It sits entirely inside the monotone model that the data had already refuted. Changing coordinates and relaxing "always down" to "decelerating" bought no flexibility at all. The boundedness of the angle quietly turns concavity back into monotonicity.

The data verdict follows at once. Between 112 and 116 bits the correlation rises, so the angle falls. That is a downward angular step, which no bounded concave sequence can take. Hence:

> **No concave model fits.** No sequence that agrees with the measured rungs can be angularly concave from any rung at or before 112 bits.

The mirror-image idea fails as well. Perhaps the angle is *convex*, decelerating downward? A convex sequence bounded above can never step up, by the same argument turned upside down. Between 116 and 120 bits the angle steps up, since the correlation drops. So:

> **No convex model fits.** No sequence that agrees with the measured rungs can be angularly convex from any rung at or before 116 bits.

## The zig-zag hidden in seven numbers

What does the ladder do, if it is neither concave nor convex? Compute the second differences: the curvature of each window of three consecutive rungs. In **both** coordinates, raw correlation and angle, their signs **alternate strictly** across all five windows. The curve bends one way, then the other, then back again, at every step. The 108-bit window is concave in angle. The very next window, at 112 bits, is convex, and strongly so: its angular second difference exceeds $0.079$ radians.

Now separate the rungs by parity, the way you might separate the black and white squares of a chessboard. The even-indexed rungs (96, 104, 112, 120) form one sub-ladder. The odd-indexed rungs (100, 108, 116) form the other. **Each sub-ladder on its own is strictly decreasing and angularly concave.** Seen through its own parity class, the "rebound" at 116 is no rebound at all: 116 still sits below 108. The apparent rise comes from comparing a rung with its neighbour from the *other* class.

The picture that emerges is a steady fade with an oscillation of period about 8 bits laid on top. No pointwise curvature condition can describe that, because the oscillation flips the sign of the curvature at every rung.

## Twist three: concavity would *force* re-entry

Here is the most striking reversal. Suppose someone insisted on a concave angle model that reproduces the 112 and 116 rungs exactly. The rebound is a downward angular step of about $0.026$ radians. A concave continuation must repeat that drop at least once per rung, so the angle must keep closing:

$$\theta_{112+4k} \le \theta_{112} - k\,(\theta_{112} - \theta_{116}).$$

The angle at 112 bits is about $1.09$ radians, and the edge of the cap is at $0.988$. Five steps of $0.026$ are more than enough to close that gap. So:

> **Concavity plus the rebound forces re-entry.** Any model that matches the 112- and 116-bit rungs and stays angularly concave for four further windows must read $\rho > 0.55$ at 132 bits.

The model built to forbid re-entry, once fitted to the rebound, *demands* it. It cannot even survive for long. With a drop of at least $0.0256$ per step from a starting angle of at most $\pi/2$, the angle would become negative within 62 steps:

> **Lifetime bound.** No such model can remain angularly concave for 62 windows.

## What survives: a guarded plateau

Not everything is lost. One clean, honest statement survives. It needs an explicit hypothesis rather than a hoped-for one. It is the **plateau localisation** principle. Suppose the angle never decreases, and each increment is at most half the previous one. Then the total future growth is bounded by a geometric series:

$$\theta_\infty - \theta_{108} \le (\theta_{112}-\theta_{108})\left(1 + \tfrac12 + \tfrac14 + \cdots\right) = 2(\theta_{112}-\theta_{108}) \le 0.0595 .$$

So the limiting angle lies in the narrow window $[\arccos 0.488,\ \arccos 0.488 + 0.0595]$, roughly $[1.061, 1.121]$ radians. That window lies entirely outside the cap. Under this model, band loss at 108 bits is permanent, and the eventual correlation lies roughly between $0.435$ and $0.488$.

The increments in this argument are controlled by a sharp, elementary inequality. For $0 \le a < b < 1$, the mean value theorem applied to arccos gives

$$\frac{b-a}{\sqrt{1-a^2}} \;\le\; \arccos a - \arccos b \;\le\; \frac{b-a}{\sqrt{1-b^2}} .$$

This turns small changes in correlation into certified changes in angle without computing a single arccos to high precision. For example, the step from $0.4847$ to $0.488$ changes the angle by between $0.003773$ and $0.003781$ radians.

The plateau theorem is honest about what it assumes. It assumes the angle never decreases. The 116 rung violates exactly that assumption. So the plateau reading is a clean *conditional* statement, not a description of the data.

## Why this matters beyond one ladder

This episode carries a lesson for anyone who fits models to a short run of measurements, such as learning curves, decay rates, or the signal strength of a physical effect across scales.

1. **Changing coordinates is not changing models.** A condition can look weaker in a new coordinate while being, because of a hidden boundedness, exactly as strong as before. Here, "concave and bounded" quietly meant "monotone".
2. **Proving the conjecture can be the refutation.** Proving the angular deceleration conjecture showed *why* it was useless. Its hypothesis already contains the falsified one.
3. **Alternating curvature is a signature.** When second differences flip sign at every point, the data are telling you there is a trend plus an oscillation. The right model separates the two and puts its smoothness assumption on the trend alone.

## A prediction you can check

Good models stick their necks out. The parity picture makes a sharp, falsifiable prediction for the next rung. If the odd sub-ladder (100, 108, 116, 124) stays strictly decreasing and angularly concave, then 124 must fall below 116, and its angle cannot exceed the chord through 108 and 116:

$$\theta_{124} \le 2\theta_{116} - \theta_{108}.$$

Translated back into correlations, this predicts

$$0.4814 \lesssim \rho_{124} < 0.4847 .$$

A window of a few thousandths. If the next measurement lands there, the oscillating-fade picture gains real support. If it lands outside, that model falls too, and we will have learned something definite either way.

The fading signal has refused to bend to any single curve. It may turn out to be telling a more interesting story: one trend, and one rhythm, braided together.
