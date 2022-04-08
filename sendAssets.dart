Future<bool> sendToken(
      String tokenAddress,
      String to,
      double amount,
      String from,
      int tokenDecimals,
      String privateKey,
      String tokenName) async {
    var amt = (amount * pow(10, tokenDecimals));

    try {
      String abi = await rootBundle.loadString("assets/abi/ERC20ABI.json");
     
      var credentials = EthPrivateKey.fromHex(privateKey);
      final ownAddress = await credentials.extractAddress();
     
      var addy = EthereumAddress.fromHex(tokenAddress);
      String contractName = tokenName + " Token";

      final contract =
          DeployedContract(ContractAbi.fromJson(abi, contractName), addy);

      final balanceFunction = contract.function('balanceOf');

      final sendFunction = contract.function('transfer');
      List balance;
      try {
        balance = await ethereumClient!.call(
            contract: contract,
            function: balanceFunction,
            params: [EthereumAddress.fromHex(contractAddress)]);
      } catch (e) {}

      await ethereumClient!
          .sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: sendFunction,
          parameters: [
            EthereumAddress.fromHex(to),
            BigInt.from(amt),
          ],
        ),
        chainId: 4,
      )
          .then((value) {
       
      });

      await ethereumClient!.dispose();

      return true;
    } catch (e, trace) {
      dev.log("Error sending assets " + e.toString());
      return false;
    }
  }
