uniform vec2 bokehOffsets[256] = vec2[](
    vec2(-0.50819844, -0.2689224),
    vec2(-0.13604361, 0.0040398836),
    vec2(-0.20659798, -0.35168433),
    vec2(-0.6846836, -0.083783746),
    vec2(0.5048299, -0.057729125),
    vec2(-0.29602528, -0.053830326),
    vec2(0.1732825, 0.7238841),
    vec2(-0.23286384, -0.574281),
    vec2(-0.7820441, -0.58903944),
    vec2(-0.09530902, 0.72179294),
    vec2(0.959283, -0.18500221),
    vec2(-0.0812853, -0.9379244),
    vec2(-0.36709976, -0.26166993),
    vec2(0.06614733, -0.007996261),
    vec2(0.13653886, -0.72988284),
    vec2(-0.5556539, 0.46785176),
    vec2(0.57750916, -0.6941725),
    vec2(-0.82620746, 0.52692413),
    vec2(0.72752523, -0.31372237),
    vec2(-0.11338878, -0.52041185),
    vec2(0.30381453, -0.40612245),
    vec2(0.12188637, -0.94267327),
    vec2(0.12747252, 0.047538996),
    vec2(-0.2649036, -0.33828127),
    vec2(0.54655766, -0.26609468),
    vec2(-0.4651628, 0.15709805),
    vec2(0.5524293, 0.7250341),
    vec2(-0.14833629, -0.7216993),
    vec2(0.70692253, -0.10371864),
    vec2(0.43646586, -0.47898066),
    vec2(0.21356487, 0.8735347),
    vec2(0.34326375, -0.55052966),
    vec2(-0.7881598, 0.442204),
    vec2(-0.22659141, -0.40716702),
    vec2(0.249807, 0.08458936),
    vec2(-0.051265895, -0.28183097),
    vec2(0.5195854, -0.40360928),
    vec2(-0.28673768, 0.0786258),
    vec2(-0.4932086, 0.6101712),
    vec2(0.5261409, 0.73308325),
    vec2(0.016994834, -0.57697284),
    vec2(0.32165623, 0.7585269),
    vec2(0.35927737, 0.8033782),
    vec2(0.717736, -0.6684308),
    vec2(-0.50923985, -0.47590017),
    vec2(0.50388265, 0.30120814),
    vec2(0.034065604, 0.2836833),
    vec2(-0.45703012, -0.0019276738),
    vec2(0.62208116, -0.30527502),
    vec2(0.83636403, -0.4603718),
    vec2(0.024376392, 0.41757607),
    vec2(-0.4670425, -0.35205328),
    vec2(-0.009768665, 0.46201026),
    vec2(0.7149193, -0.14172912),
    vec2(0.0821681, -0.8943649),
    vec2(-0.44643116, -0.34696788),
    vec2(-0.18184447, -0.5017258),
    vec2(-0.59339684, 0.7280954),
    vec2(0.08929074, 0.029649496),
    vec2(-0.44618064, 0.13577938),
    vec2(-0.30996025, 0.8721106),
    vec2(0.5986022, 0.0949806),
    vec2(0.86111057, -0.38664836),
    vec2(0.16747451, 0.22448993),
    vec2(0.20058954, -0.8221329),
    vec2(0.053818226, -0.050893545),
    vec2(0.83038116, -0.49461615),
    vec2(0.6205449, -0.268152),
    vec2(-0.5840019, 0.40727186),
    vec2(-0.055127084, -0.8904268),
    vec2(0.44167316, -0.8006371),
    vec2(0.2354505, -0.827374),
    vec2(-0.8247087, -0.01591438),
    vec2(0.2918676, -0.21708703),
    vec2(0.12846828, 0.12547815),
    vec2(0.6829252, 0.22941136),
    vec2(0.080212355, -0.9754849),
    vec2(-0.46399117, -0.36292344),
    vec2(0.6823838, 0.45144022),
    vec2(0.9476955, -0.18653464),
    vec2(-0.56896853, -0.30820566),
    vec2(-0.7556414, -0.613449),
    vec2(0.89645934, 0.2620988),
    vec2(-0.5657723, 0.3944031),
    vec2(0.0011098385, 0.19627726),
    vec2(0.05898106, 0.6683036),
    vec2(0.72247314, -0.59162056),
    vec2(-0.38359684, -0.16955954),
    vec2(-0.58405125, 0.74558413),
    vec2(-0.6553556, 0.06376994),
    vec2(0.09525859, -0.6774928),
    vec2(-0.17912948, -0.63846266),
    vec2(0.28596258, -0.25953305),
    vec2(-0.05836183, 0.6836165),
    vec2(0.24418652, 0.8239919),
    vec2(0.3356489, 0.40486515),
    vec2(0.66830564, 0.44243097),
    vec2(-0.6255994, -0.1296683),
    vec2(0.56944597, -0.12467444),
    vec2(0.49784493, -0.012912214),
    vec2(0.2992041, 0.56765985),
    vec2(-0.34734416, -0.31820172),
    vec2(-0.28581214, 0.5047699),
    vec2(0.14217377, 0.007446766),
    vec2(-0.16189009, 0.57185674),
    vec2(0.4615649, -0.3602149),
    vec2(0.4702971, -0.8666464),
    vec2(0.1033932, 0.91616595),
    vec2(-0.5912825, 0.42596674),
    vec2(-0.3901546, 0.32165837),
    vec2(-0.15136003, -0.2543686),
    vec2(0.5186235, -0.8244662),
    vec2(-0.9280785, 0.17022145),
    vec2(-0.5040322, -0.85175776),
    vec2(-0.76631653, 0.18295431),
    vec2(-0.32511365, 0.3358444),
    vec2(-0.72224355, 0.0035731792),
    vec2(0.2831334, 0.55496633),
    vec2(0.7600843, -0.6014085),
    vec2(-0.5039377, -0.31814814),
    vec2(-0.80622643, 0.18044555),
    vec2(0.28851235, 0.83517396),
    vec2(-0.3471536, -0.13313782),
    vec2(0.46656466, 0.64365995),
    vec2(0.025781393, 0.5777844),
    vec2(0.5158318, -0.175345),
    vec2(-0.61432695, 0.33935726),
    vec2(0.23405838, -0.6527444),
    vec2(-0.34578884, 0.5345266),
    vec2(0.3114226, 0.8234812),
    vec2(0.6733577, 0.7310976),
    vec2(-0.088876784, 0.3602842),
    vec2(0.71339464, 0.4032451),
    vec2(-0.40140742, -0.6682624),
    vec2(0.40829277, 0.32491374),
    vec2(-0.30626225, -0.21774518),
    vec2(-0.13306063, 0.77448547),
    vec2(-0.67026836, -0.05084914),
    vec2(0.8480331, -0.28698885),
    vec2(0.26951194, -0.13601798),
    vec2(0.048870683, 0.90686023),
    vec2(0.33091938, -0.64325976),
    vec2(-0.21175092, 0.32702196),
    vec2(-0.7245549, 0.28589416),
    vec2(-0.099537134, -0.075363696),
    vec2(-0.5202976, 0.14061797),
    vec2(-0.17799097, -0.23851734),
    vec2(-0.4824211, 0.044364095),
    vec2(-0.16542393, -0.75649405),
    vec2(0.7945342, -0.47534436),
    vec2(0.4348774, -0.41246003),
    vec2(0.6255392, -0.5607381),
    vec2(-0.7300628, -0.09885782),
    vec2(0.6174605, -0.0073317885),
    vec2(0.25574303, -0.5373602),
    vec2(0.89009166, 0.33297443),
    vec2(0.0670681, -0.9669735),
    vec2(-0.6831011, -0.7243421),
    vec2(-0.7870146, -0.018609107),
    vec2(-0.22495317, 0.4573208),
    vec2(-0.5860218, 0.56725),
    vec2(0.13165045, -0.69351375),
    vec2(-0.683818, -0.62857056),
    vec2(0.12814331, -0.79559946),
    vec2(0.6188171, 0.36735165),
    vec2(0.8619808, -0.18151271),
    vec2(-0.10703421, -0.24318647),
    vec2(-0.16417903, 0.6375309),
    vec2(0.8701806, 0.37145042),
    vec2(0.14734852, -0.14430511),
    vec2(-0.8199307, 0.13228369),
    vec2(0.56271446, 0.6881139),
    vec2(-0.47686398, -0.5623425),
    vec2(0.022525907, 0.8231224),
    vec2(0.8645359, 0.2204237),
    vec2(0.9293331, 0.21462607),
    vec2(0.33131003, -0.15890735),
    vec2(-0.071267724, -0.59260505),
    vec2(0.5403421, -0.4013661),
    vec2(0.781142, 0.065246105),
    vec2(-0.585285, -0.08674735),
    vec2(-0.38387406, -0.5561267),
    vec2(-0.29803455, -0.5835321),
    vec2(-0.71882904, 0.00085270405),
    vec2(0.89212644, 0.25082707),
    vec2(-0.59490037, -0.7770252),
    vec2(-0.7116282, -0.4398799),
    vec2(0.46568882, 0.50435185),
    vec2(0.3139534, 0.35329473),
    vec2(0.22129893, -0.74719924),
    vec2(0.61600685, -0.59616077),
    vec2(0.73542285, -0.2762069),
    vec2(0.15891922, 0.6737561),
    vec2(0.62820363, -0.20804536),
    vec2(0.025383234, 0.40370345),
    vec2(-0.8149401, 0.3170991),
    vec2(-0.11339724, -0.101737976),
    vec2(0.8352363, -0.24801195),
    vec2(-0.11012232, 0.49503517),
    vec2(0.14551508, -0.5908234),
    vec2(-0.18055779, -0.47003227),
    vec2(-0.5574492, 0.43874764),
    vec2(-0.34498125, -0.5527464),
    vec2(0.7361388, 0.4014156),
    vec2(-0.6037268, -0.15464658),
    vec2(0.29880106, -0.31542343),
    vec2(-0.67387736, -0.3967331),
    vec2(-0.19700497, -0.12410909),
    vec2(0.3539536, 0.09282756),
    vec2(-0.12175727, 0.59813964),
    vec2(-0.014836252, 0.17340457),
    vec2(-0.70054114, -0.1618014),
    vec2(0.17917717, 0.7511753),
    vec2(0.8832079, 0.049206734),
    vec2(0.03429532, -0.55401886),
    vec2(-0.8331329, 0.26258254),
    vec2(-0.2456764, 0.8195075),
    vec2(-0.14099443, 0.05393386),
    vec2(0.084409, -0.13369668),
    vec2(0.3061825, 0.035670757),
    vec2(-0.7770996, 0.17552066),
    vec2(0.15559292, 0.6837888),
    vec2(0.35583556, -0.3616578),
    vec2(-0.19223124, -0.0838145),
    vec2(-0.7666238, 0.32653594),
    vec2(0.2645743, -0.44391656),
    vec2(-0.41185755, -0.77367324),
    vec2(-0.47482914, -0.6444899),
    vec2(0.030919313, 0.5020325),
    vec2(0.5645226, -0.27110714),
    vec2(0.6193743, -0.54557395),
    vec2(-0.5596827, -0.6153214),
    vec2(0.8707905, 0.011560559),
    vec2(0.7145399, -0.05433756),
    vec2(-0.19314283, -0.97471786),
    vec2(-0.7972544, 0.18503928),
    vec2(-0.68805313, -0.52979183),
    vec2(0.901513, -0.32456994),
    vec2(-0.6124219, -0.41074353),
    vec2(0.5255456, -0.12507904),
    vec2(-0.5441185, 0.483706),
    vec2(-0.5534384, 0.4981817),
    vec2(0.19619703, 0.83588874),
    vec2(-0.10324597, -0.9256425),
    vec2(0.51760507, -0.654889),
    vec2(0.036031842, -0.9805355),
    vec2(0.023096204, 0.21560097),
    vec2(-0.67342937, -0.61552465),
    vec2(-0.034275055, 0.86054564),
    vec2(-0.30683315, -0.20378458),
    vec2(0.39545202, 0.6808851),
    vec2(-0.029159546, 0.32173216),
    vec2(0.90845585, -0.29109317),
    vec2(-0.03239107, -0.5109131),
    vec2(0.17307603, -0.74802816),
    vec2(0.16380298, -0.75347745)
);