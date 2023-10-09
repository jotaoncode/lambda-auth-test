const path = require("path");
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');

module.exports = {
  mode: "production",
  entry: {
    login: './src/login/index.ts',
    signup: './src/signup/index.ts'
  },
  resolve: {
    extensions: [".ts", ".js"],
  },
  output: {
    libraryTarget: "umd",
    path: path.join(__dirname, "dist"),
    filename: '[name].js',
  },
  target: "node",
  module: {
    rules: [
      { test: /\.([cm]?ts|tsx)$/, loader: "ts-loader" }
    ],
  },
  plugins: [new ForkTsCheckerWebpackPlugin()],
};