var path = require('path');

module.exports = {
    mode: 'development',
    entry: path.join(__dirname, 'srcjs', 'shiny-react.jsx'),
    output: {
        path: path.join(__dirname, 'inst', 'www', 'shiny.react'),
        filename: 'shiny-react.js'
    },
    module: {
        rules: [
            {
                test: /\.jsx?$/,
                loader: 'babel-loader',
                options: {
                    presets: ['@babel/preset-env', '@babel/preset-react']
                }
            }
        ]
    },
    externals: {
        'react': 'window.React',
        'react-dom': 'window.ReactDOM',
        'jquery': 'window.jQuery',
        'shiny': 'window.Shiny'
    },
    stats: {
        colors: true
    },
    devtool: 'source-map'
};
