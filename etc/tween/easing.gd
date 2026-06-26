class_name Easing

## Robert Penner easing functions.
## All follow the signature (t, b, c, d) where:
##   t = current time
##   b = beginning value
##   c = change in value (end - begin)
##   d = duration

enum Type {
	LINEAR,
	SINE_IN, SINE_OUT, SINE_IN_OUT,
	QUAD_IN, QUAD_OUT, QUAD_IN_OUT,
	CUBIC_IN, CUBIC_OUT, CUBIC_IN_OUT,
	QUART_IN, QUART_OUT, QUART_IN_OUT,
	QUINT_IN, QUINT_OUT, QUINT_IN_OUT,
	EXPO_IN, EXPO_OUT, EXPO_IN_OUT,
	CIRC_IN, CIRC_OUT, CIRC_IN_OUT,
	BACK_IN, BACK_OUT, BACK_IN_OUT,
	ELASTIC_IN, ELASTIC_OUT, ELASTIC_IN_OUT,
	BOUNCE_IN, BOUNCE_OUT, BOUNCE_IN_OUT,
}


static func ease_func(type: Type, t: float, b: float, c: float, d: float) -> float:
	match type:
		Type.LINEAR: return linear(t, b, c, d)
		Type.SINE_IN: return sine_in(t, b, c, d)
		Type.SINE_OUT: return sine_out(t, b, c, d)
		Type.SINE_IN_OUT: return sine_in_out(t, b, c, d)
		Type.QUAD_IN: return quad_in(t, b, c, d)
		Type.QUAD_OUT: return quad_out(t, b, c, d)
		Type.QUAD_IN_OUT: return quad_in_out(t, b, c, d)
		Type.CUBIC_IN: return cubic_in(t, b, c, d)
		Type.CUBIC_OUT: return cubic_out(t, b, c, d)
		Type.CUBIC_IN_OUT: return cubic_in_out(t, b, c, d)
		Type.QUART_IN: return quart_in(t, b, c, d)
		Type.QUART_OUT: return quart_out(t, b, c, d)
		Type.QUART_IN_OUT: return quart_in_out(t, b, c, d)
		Type.QUINT_IN: return quint_in(t, b, c, d)
		Type.QUINT_OUT: return quint_out(t, b, c, d)
		Type.QUINT_IN_OUT: return quint_in_out(t, b, c, d)
		Type.EXPO_IN: return expo_in(t, b, c, d)
		Type.EXPO_OUT: return expo_out(t, b, c, d)
		Type.EXPO_IN_OUT: return expo_in_out(t, b, c, d)
		Type.CIRC_IN: return circ_in(t, b, c, d)
		Type.CIRC_OUT: return circ_out(t, b, c, d)
		Type.CIRC_IN_OUT: return circ_in_out(t, b, c, d)
		Type.BACK_IN: return back_in(t, b, c, d)
		Type.BACK_OUT: return back_out(t, b, c, d)
		Type.BACK_IN_OUT: return back_in_out(t, b, c, d)
		Type.ELASTIC_IN: return elastic_in(t, b, c, d)
		Type.ELASTIC_OUT: return elastic_out(t, b, c, d)
		Type.ELASTIC_IN_OUT: return elastic_in_out(t, b, c, d)
		Type.BOUNCE_IN: return bounce_in(t, b, c, d)
		Type.BOUNCE_OUT: return bounce_out(t, b, c, d)
		Type.BOUNCE_IN_OUT: return bounce_in_out(t, b, c, d)
	return linear(t, b, c, d)


# -- Linear --

static func linear(t: float, b: float, c: float, d: float) -> float:
	return c * t / d + b


# -- Sine --

static func sine_in(t: float, b: float, c: float, d: float) -> float:
	return -c * cos(t / d * (PI / 2.0)) + c + b

static func sine_out(t: float, b: float, c: float, d: float) -> float:
	return c * sin(t / d * (PI / 2.0)) + b

static func sine_in_out(t: float, b: float, c: float, d: float) -> float:
	return -c / 2.0 * (cos(PI * t / d) - 1.0) + b


# -- Quadratic --

static func quad_in(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	return c * t2 * t2 + b

static func quad_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	return -c * t2 * (t2 - 2.0) + b

static func quad_in_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return c / 2.0 * t2 * t2 + b
	t2 -= 1.0
	return -c / 2.0 * (t2 * (t2 - 2.0) - 1.0) + b


# -- Cubic --

static func cubic_in(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	return c * t2 * t2 * t2 + b

static func cubic_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d - 1.0
	return c * (t2 * t2 * t2 + 1.0) + b

static func cubic_in_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return c / 2.0 * t2 * t2 * t2 + b
	t2 -= 2.0
	return c / 2.0 * (t2 * t2 * t2 + 2.0) + b


# -- Quartic --

static func quart_in(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	return c * t2 * t2 * t2 * t2 + b

static func quart_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d - 1.0
	return -c * (t2 * t2 * t2 * t2 - 1.0) + b

static func quart_in_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return c / 2.0 * t2 * t2 * t2 * t2 + b
	t2 -= 2.0
	return -c / 2.0 * (t2 * t2 * t2 * t2 - 2.0) + b


# -- Quintic --

static func quint_in(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	return c * t2 * t2 * t2 * t2 * t2 + b

static func quint_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d - 1.0
	return c * (t2 * t2 * t2 * t2 * t2 + 1.0) + b

static func quint_in_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return c / 2.0 * t2 * t2 * t2 * t2 * t2 + b
	t2 -= 2.0
	return c / 2.0 * (t2 * t2 * t2 * t2 * t2 + 2.0) + b


# -- Exponential --

static func expo_in(t: float, b: float, c: float, d: float) -> float:
	if t == 0.0:
		return b
	return c * pow(2.0, 10.0 * (t / d - 1.0)) + b

static func expo_out(t: float, b: float, c: float, d: float) -> float:
	if t == d:
		return b + c
	return c * (-pow(2.0, -10.0 * t / d) + 1.0) + b

static func expo_in_out(t: float, b: float, c: float, d: float) -> float:
	if t == 0.0:
		return b
	if t == d:
		return b + c
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return c / 2.0 * pow(2.0, 10.0 * (t2 - 1.0)) + b
	t2 -= 1.0
	return c / 2.0 * (-pow(2.0, -10.0 * t2) + 2.0) + b


# -- Circular --

static func circ_in(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	return -c * (sqrt(1.0 - t2 * t2) - 1.0) + b

static func circ_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d - 1.0
	return c * sqrt(1.0 - t2 * t2) + b

static func circ_in_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return -c / 2.0 * (sqrt(1.0 - t2 * t2) - 1.0) + b
	t2 -= 2.0
	return c / 2.0 * (sqrt(1.0 - t2 * t2) + 1.0) + b


# -- Back --

static func back_in(t: float, b: float, c: float, d: float, s: float = 1.70158) -> float:
	var t2 := t / d
	return c * t2 * t2 * ((s + 1.0) * t2 - s) + b

static func back_out(t: float, b: float, c: float, d: float, s: float = 1.70158) -> float:
	var t2 := t / d - 1.0
	return c * (t2 * t2 * ((s + 1.0) * t2 + s) + 1.0) + b

static func back_in_out(t: float, b: float, c: float, d: float, s: float = 1.70158) -> float:
	var s2 := s * 1.525
	var t2 := t / (d / 2.0)
	if t2 < 1.0:
		return c / 2.0 * (t2 * t2 * ((s2 + 1.0) * t2 - s2)) + b
	t2 -= 2.0
	return c / 2.0 * (t2 * t2 * ((s2 + 1.0) * t2 + s2) + 2.0) + b


# -- Elastic --

static func elastic_in(t: float, b: float, c: float, d: float) -> float:
	if t == 0.0:
		return b
	var t2 := t / d
	if t2 == 1.0:
		return b + c
	var p := d * 0.3
	var s := p / 4.0
	t2 -= 1.0
	return -(c * pow(2.0, 10.0 * t2) * sin((t2 * d - s) * (2.0 * PI) / p)) + b

static func elastic_out(t: float, b: float, c: float, d: float) -> float:
	if t == 0.0:
		return b
	var t2 := t / d
	if t2 == 1.0:
		return b + c
	var p := d * 0.3
	var s := p / 4.0
	return c * pow(2.0, -10.0 * t2) * sin((t2 * d - s) * (2.0 * PI) / p) + c + b

static func elastic_in_out(t: float, b: float, c: float, d: float) -> float:
	if t == 0.0:
		return b
	var t2 := t / (d / 2.0)
	if t2 == 2.0:
		return b + c
	var p := d * 0.45
	var s := p / 4.0
	if t2 < 1.0:
		t2 -= 1.0
		return -0.5 * (c * pow(2.0, 10.0 * t2) * sin((t2 * d - s) * (2.0 * PI) / p)) + b
	t2 -= 1.0
	return c * pow(2.0, -10.0 * t2) * sin((t2 * d - s) * (2.0 * PI) / p) * 0.5 + c + b


# -- Bounce --

static func bounce_out(t: float, b: float, c: float, d: float) -> float:
	var t2 := t / d
	if t2 < 1.0 / 2.75:
		return c * (7.5625 * t2 * t2) + b
	elif t2 < 2.0 / 2.75:
		t2 -= 1.5 / 2.75
		return c * (7.5625 * t2 * t2 + 0.75) + b
	elif t2 < 2.5 / 2.75:
		t2 -= 2.25 / 2.75
		return c * (7.5625 * t2 * t2 + 0.9375) + b
	else:
		t2 -= 2.625 / 2.75
		return c * (7.5625 * t2 * t2 + 0.984375) + b

static func bounce_in(t: float, b: float, c: float, d: float) -> float:
	return c - bounce_out(d - t, 0.0, c, d) + b

static func bounce_in_out(t: float, b: float, c: float, d: float) -> float:
	if t < d / 2.0:
		return bounce_in(t * 2.0, 0.0, c, d) * 0.5 + b
	return bounce_out(t * 2.0 - d, 0.0, c, d) * 0.5 + c * 0.5 + b
