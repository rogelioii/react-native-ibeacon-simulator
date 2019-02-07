/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, { Component } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import BeaconBroadcast from 'react-native-ibeacon-simulator';
import uuid from 'uuid/v4';

type Props = {};
export default class App extends Component<Props> {

  componentWillMount() {
    BeaconBroadcast.startAdvertisingBeaconWithString(
      uuid(), 
      'Example App Beacon',
      100,
      0
    );
  }

  render() {
    return (
      <View style={styles.container}>
        <Text>Beacon Broadcast example</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
