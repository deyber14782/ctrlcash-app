import 'dart:math';

class FinanceQuotes {
  static const List<String> _quotes = [
    'No se trata de cuánto ganas, sino de cuánto conservas.',
    'Un presupuesto le dice a tu dinero a dónde ir, en vez de preguntarte a dónde se fue.',
    'Gasta menos de lo que ganas e invierte la diferencia.',
    'La riqueza no se mide por lo que gastas, sino por lo que ahorras.',
    'Cada peso que ahorras hoy es libertad para tu yo del futuro.',
    'Las pequeñas fugas hunden grandes barcos: cuida los gastos pequeños.',
    'El control de tu dinero empieza por conocer a dónde va.',
    'Ahorrar no es privarse, es elegir con intención.',
    'Quien no planifica sus finanzas, planifica sin saberlo su escasez.',
    'La disciplina financiera de hoy es la tranquilidad de mañana.',
    'El dinero es un buen sirviente, pero un mal amo.',
    'Pagarte a ti primero es la base de toda fortuna.',
    'No ahorres lo que queda después de gastar; gasta lo que queda después de ahorrar.',
    'La libertad financiera empieza cuando dejas de comprar cosas que no necesitas.',
    'Un gasto pequeño repetido cada día se convierte en una fuga enorme cada año.',
    'Invertir en tu educación financiera siempre paga los mejores intereses.',
    'El interés compuesto es la octava maravilla: quien lo entiende, lo cobra.',
    'Antes de comprar, pregúntate si lo necesitas o solo lo deseas.',
    'Tener un fondo de emergencia es dormir tranquilo.',
    'La deuda es esclavitud con cuotas mensuales.',
    'No trabajes solo por dinero; haz que el dinero trabaje por ti.',
    'Lo barato muchas veces sale caro; lo planificado siempre sale a cuenta.',
    'Tu patrimonio crece en silencio, peso a peso, decisión a decisión.',
    'Registrar tus gastos es el primer paso para dominarlos.',
    'El presupuesto no te limita, te da poder sobre tu dinero.',
    'Cada decisión de hoy construye la billetera de mañana.',
    'Ahorrar es pagarte un sueldo a tu futuro.',
    'La riqueza real es tener opciones, no objetos.',
    'Controla tus impulsos y controlarás tus finanzas.',
    'No es cuánto dinero haces, sino cuánto dinero te queda y por cuánto tiempo.',
    'Las metas sin presupuesto son solo deseos.',
    'Gastar con conciencia hoy es vivir con holgura mañana.',
    'El que ahorra siempre tiene; el que gasta siempre debe.',
    'Mide cada gasto: lo que no se mide, no se mejora.',
    'La paciencia financiera convierte centavos en patrimonio.',
    'Vive por debajo de tus posibilidades para vivir por encima de tus sueños.',
    'Cada vez que evitas un gasto innecesario, te haces más libre.',
    'El dinero rinde más cuando tiene un plan que seguir.',
    'No persigas lujos prestados; construye riqueza propia.',
    'Tu yo del futuro agradecerá cada peso que cuides hoy.',
  ];

  static int? _lastIndex;

  static String random() {
    final rnd = Random();
    int i;
    do {
      i = rnd.nextInt(_quotes.length);
    } while (i == _lastIndex && _quotes.length > 1);
    _lastIndex = i;
    return _quotes[i];
  }
}
