<?php 


function convertVariableToString($json) {
    foreach ($json as $objectName => $variables) {
        foreach ($variables as $variableName => $combinations) {
            if (in_array($variableName, array('variables', 'variableDefault'))) {
                $newCombinations = array();
                foreach ($combinations as $combinationName => $values) {
                    if (is_array($values)) {
                        foreach ($values as $key => $value) {
                            if (is_numeric($value)) {
                                $newCombinations[$combinationName][] = $value . '';
                            } else {
                                $newCombinations[$combinationName][] = $value;
                            }
                        }
                    } else {
                        $newCombinations[$combinationName] = $values . '';
                    }
                }

                $json[$objectName][$variableName] = $newCombinations;
            }
        }
    }

    //print_r($json);exit;
    return $json;
}


/**
 * Indents a flat JSON string to make it more human-readable.
 *
 * @param string $json The original JSON string to process.
 *
 * @return string Indented version of the original JSON string.
 */
function jsonBeautifier($json) {

    $result      = '';
    $pos         = 0;
    $strLen      = strlen($json);
    $indentStr   = '  ';
    $newLine     = "\n";
    $prevChar    = '';
    $outOfQuotes = true;

    for ($i=0; $i<=$strLen; $i++) {

        // Grab the next character in the string.
        $char = substr($json, $i, 1);

        // Are we inside a quoted string?
        if ($char == '"' && $prevChar != '\\') {
            $outOfQuotes = !$outOfQuotes;

        // If this character is the end of an element,
        // output a new line and indent the next line.
        } else if(($char == '}' || $char == ']') && $outOfQuotes) {
            $result .= $newLine;
            $pos --;
            for ($j=0; $j<$pos; $j++) {
                $result .= $indentStr;
            }
        }

        // Add the character to the result string.
        $result .= $char;

        // If the last character was the beginning of an element,
        // output a new line and indent the next line.
        if (($char == ',' || $char == '{' || $char == '[') && $outOfQuotes) {
            $result .= $newLine;
            if ($char == '{' || $char == '[') {
                $pos ++;
            }

            for ($j = 0; $j < $pos; $j++) {
                $result .= $indentStr;
            }
        }

        $prevChar = $char;
    }

    return $result;
}