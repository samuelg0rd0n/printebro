<?php

namespace ADT;

/**
 */
class NamingStrategy implements \Doctrine\ORM\Mapping\NamingStrategy {

	/**
	 * {@inheritdoc}
	 */
	public function classToTableName($className) {
		if (strpos($className, '\\') !== false) {
			$className = substr($className, strrpos($className, '\\') + 1);
		}

		return $this->underscore($className);
	}

	/**
	 * {@inheritdoc}
	 */
	public function propertyToColumnName($propertyName, $className = null) {
		return $propertyName;
	}

	/**
	 * {@inheritdoc}
	 */
	public function referenceColumnName() {
		return 'id';
	}

	/**
	 * {@inheritdoc}
	 */
	public function joinColumnName($propertyName) {
		return $propertyName . '_' . $this->referenceColumnName();
	}

	/**
	 * {@inheritdoc}
	 */
	public function joinTableName($sourceEntity, $targetEntity, $propertyName = null) {
		return $this->classToTableName($sourceEntity) . '_' . $this->classToTableName($targetEntity);
	}

	/**
	 * {@inheritdoc}
	 */
	public function joinKeyColumnName($entityName, $referencedColumnName = null) {
		return $this->classToTableName($entityName) . '_' .
			($referencedColumnName ? : $this->referenceColumnName());
	}

	/**
	 * @param string $string
	 *
	 * @return string
	 */
	private function underscore($string) {
		$string = preg_replace('/(?<=[a-z])([A-Z])/', '_$1', $string);

		return strtolower($string);
	}

	function embeddedFieldToColumnName($propertyName, $embeddedColumnName, $className = null, $embeddedClassName = null)
	{
		// TODO: added empty implementation after doctrine composer update
	}

}
