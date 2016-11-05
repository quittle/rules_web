// Comment
/**
 * @fileoverview Test file
 */

var a = 3;

(function() {
    function a(a) {}
    var unused = 'value';
    a(unused);
    console.log('message');
})();

/**
 * No comment
 */
const value = 'pizza';
console.log('Message ' + value);
