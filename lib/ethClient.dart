import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';

class EthClient {
  final rpcUrl = 'HTTP://127.0.0.1:7545';
  final privateKey = '3a3fa2ddc9114d8b5c26cbecee513f2ee14912ce6043520dcf12fa7c819753f5';

  late final Client _httpClient = Client();
  late final Web3Client _ethClient = Web3Client(rpcUrl, _httpClient);

  late final Credentials _credentials;
  late final EthereumAddress _myAddress;

  late String _abi;
  late final EthereumAddress _contractAddress;

  late final DeployedContract _contract;
  late final ContractFunction getCounter, increment;
  late final ContractEvent counterIncremented;

  Future<void> init() async {
    await _getCredentials();
    await _getDeployedContract();
    await _getContractFunctions();
  }

  Future<void> _getCredentials() async {
    _credentials = await _ethClient.credentialsFromPrivateKey(privateKey);
    _myAddress = await _credentials.extractAddress();
  }

  Future<void> _getDeployedContract() async {
    final abiString = await rootBundle.loadString('build/contracts/Counter.json');
    final abiJson = jsonDecode(abiString);
    _abi = jsonEncode(abiJson['abi']);

    _contractAddress = EthereumAddress.fromHex(abiJson['networks']['5777']['address']);
  }

  Future<void> _getContractFunctions() async {
    _contract = DeployedContract(ContractAbi.fromJson(_abi, "Counter"), _contractAddress);

    getCounter = _contract.function('counter');
    increment = _contract.function('increment');
    counterIncremented = _contract.event('CounterIncremented');
  }

  Stream<FilterEvent> listenToEvents() => _ethClient.events(FilterOptions.events(
        contract: _contract,
        event: counterIncremented,
      ));

  Future<List<dynamic>> readContract(
      ContractFunction functionName, List<dynamic> functionArgs) async {
    final queryResult = await _ethClient.call(
      contract: _contract,
      function: functionName,
      params: functionArgs,
    );

    return queryResult;
  }

  Future<void> writeContract(ContractFunction functionName, List<dynamic> functionArgs) async {
    await _ethClient.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );
  }
}
