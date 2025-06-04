<?php

declare(strict_types=1);
use PhpCsFixer\Config;
use PhpCsFixer\ConfigurationException\InvalidConfigurationException;
use PhpCsFixer\Finder;
use PhpCsFixer\FixerFactory;
use PhpCsFixer\RuleSet;

/*
 * This file is part of PHP CS Fixer.
 * (c) Fabien Potencier <fabien@symfony.com>
 *     Dariusz Rumiński <dariusz.ruminski@gmail.com>
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

$header = <<<'EOF'
This file is part of PHP CS Fixer.
(c) Fabien Potencier <fabien@symfony.com>
    Dariusz Rumiński <dariusz.ruminski@gmail.com>
This source file is subject to the MIT license that is bundled
with this source code in the file LICENSE.
EOF;

$finder = Finder::create()
    ->exclude('tests/Fixtures')
    ->in(__DIR__)
    ->exclude('.ssh')
    ->append([
        __DIR__ . '/dev-tools/doc.php',
        // __DIR__.'/php-cs-fixer', disabled, as we want to be able to run bootstrap file even on lower PHP version, to show nice message
    ])
;

$config = new Config();
$config
    ->setRiskyAllowed(true)
    ->setRules([
        '@PHP71Migration:risky'               => true,
        '@PHPUnit75Migration:risky'           => true,
        '@PhpCsFixer'                         => true,
        '@PhpCsFixer:risky'                   => false,
        'binary_operator_spaces'              => ['default' => 'align_single_space_minimal'],
        'blank_line_before_statement'         => ['statements' => ['continue', 'declare', 'return', 'throw', 'try']],
        'concat_space'                        => ['spacing' => 'one'],
        'declare_strict_types'                => true,
        'general_phpdoc_annotation_remove'    => ['annotations' => ['expectedDeprecation']],
        'global_namespace_import'             => false,
        'increment_style'                     => ['style' => 'post'],
        'php_unit_internal_class'             => false,
        'php_unit_method_casing'              => ['case' => 'snake_case'],
        'php_unit_test_class_requires_covers' => false,
        'yoda_style'                          => false,
        // 'header_comment' => ['header' => $header],
    ])
    ->setFinder($finder)
;

// special handling of fabbot.io service if it's using too old PHP CS Fixer version
if (false !== getenv('FABBOT_IO')) {
    try {
        FixerFactory::create()
            ->registerBuiltInFixers()
            ->registerCustomFixers($config->getCustomFixers())
            ->useRuleSet(new RuleSet($config->getRules()))
        ;
    } catch (InvalidConfigurationException $e) {
        $config->setRules([]);
    } catch (UnexpectedValueException $e) {
        $config->setRules([]);
    } catch (InvalidArgumentException $e) {
        $config->setRules([]);
    }
}

return $config;
