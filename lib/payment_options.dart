import 'package:flutter/material.dart';

class PaymentOptions extends StatefulWidget {
  const PaymentOptions({super.key});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0, // Prevents elevation change on scroll
        shadowColor: Colors.transparent, // Removes shadow when scrolling
        surfaceTintColor: Colors.transparent, // Removes surface tint effect
        elevation: 0,
        title: const Text("Payment Methods"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),
                const Text(
                  "All Payment Options",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _buildPaymentExpansionTile(
                  "UPI",
                  "assets/payment/upi_logo.png",
                  "Get upto Rs. 300 off on Swiggy",
                  [
                    _buildPaymentMethod("Google Pay", "assets/payment/gpay_logo.png"),
                    _buildPaymentMethod("PhonePe", "assets/payment/phonepe_logo.png"),
                    _buildPaymentMethod("Paytm", "assets/payment/paytm_logo.png"),
                    _buildPaymentMethod("BHIM", "assets/payment/bhim_logo.png"),
                  ],
                ),

                _buildPaymentExpansionTile(
                  "Debit Card / Credit Card",
                  "assets/payment/card_logo.png",
                  "RuPay, Visa, Mastercard...",
                  [
                    _buildPaymentMethod("RuPay", "assets/payment/rupay_logo.png"),
                    _buildPaymentMethod("Visa", "assets/payment/visa_logo.png"),
                    _buildPaymentMethod("Master Card", "assets/payment/master-card_logo.png"),
                    _buildPaymentMethod("American Express", "assets/payment/american-express_logo.png"),
                  ],
                ),

                _buildPaymentExpansionTile(
                  "Netbanking",
                  "assets/payment/bank_logo.png",
                  "HDFC, SBI, ICICI...",
                  [
                    _buildPaymentMethod("HDFC Bank", "assets/payment/hdfc_logo.png"),
                    _buildPaymentMethod("SBI Bank", "assets/payment/sbi_logo.png"),
                    _buildPaymentMethod("ICICI Bank", "assets/payment/icici_logo.png"),
                    _buildPaymentMethod("Axis Bank", "assets/payment/axis_logo.png"),
                    _buildPaymentMethod("Axis Bank", "assets/payment/bob_logo.png"),
                    _buildPaymentMethod("Axis Bank", "assets/payment/kotak_logo.png"),
                  ],
                ),

                _buildPaymentExpansionTile(
                  "Wallet",
                  "assets/payment/wallet_logo.png",
                  "Multiple wallet options",
                  [
                    _buildPaymentMethod("Mobikwik", "assets/payment/mobikwik_logo.png"),
                    _buildPaymentMethod("Airtel Payments", "assets/payment/airtel_logo.png"),
                    _buildPaymentMethod("Ola Money", "assets/payment/ola_money_logo.png"),
                    _buildPaymentMethod("JioMoney", "assets/payment/jio_money_logo.png"),
                    _buildPaymentMethod("Freecharge", "assets/payment/freecharge_logo.png"),
                  ],
                ),
                ListTile(
                  leading:Image.asset("assets/payment/cash-on-delivery_logo.png",height: 30,width: 30,),
                  title: Text('Cash On Delivery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentExpansionTile(
      String title,
      String logoPath,
      String subtitle,
      List<Widget> children,
      ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        leading: Image.asset(
          logoPath,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.payment, color: Colors.blue);
          },
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        children: children,
      ),
    );
  }

  Widget _buildPaymentMethod(String name, String logoPath) {
    return ListTile(
      leading: Image.asset(
        logoPath,
        width: 30,
        height: 30,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.payment, color: Colors.grey);
        },
      ),
      title: Text(name),
    );
  }
}
